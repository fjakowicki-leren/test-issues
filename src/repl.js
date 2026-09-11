import { spawnSync } from "node:child_process";
import {
  commit,
  currentBranch,
  diff,
  hasAnyChanges,
  hasStagedChanges,
  log,
  pull,
  push,
  shortStatus,
  stageAll,
} from "./git.js";
import { applyPrefix } from "./session.js";
import { askLine, c, clipTitle, printBlock } from "./ui.js";

function help() {
  console.log(`
  ${c.bold("Escribí el mensaje y Enter")} para commitear con el prefijo del issue.

  ${c.cyan("/status")}   estado del repo          ${c.cyan("/diff")}     cambios sin commitear
  ${c.cyan("/add")}      stagea todo              ${c.cyan("/log")}      últimos commits
  ${c.cyan("/push")}     envía a origin           ${c.cyan("/pull")}     trae de origin
  ${c.cyan("/issue")}    cambiar de issue         ${c.cyan("/exit")}     salir del entorno
  ${c.cyan("!<cmd>")}    ejecuta un comando en la shell
`);
}

function runShell(command) {
  const result = spawnSync(command, { shell: true, stdio: "inherit" });
  return result.status ?? 1;
}

function report({ status, out }, okMessage) {
  printBlock(out);
  if (status === 0) {
    if (okMessage) console.log(c.green(`  ${okMessage}`));
    return true;
  }
  return false;
}

/** Prompt de ancho fijo: el título va arriba para que el input no se mueva. */
function promptFor(session) {
  return `${c.green(`[#${session.number}]`)} ${c.dim("›")} `;
}

function printTitle(session) {
  const title = clipTitle(session.title);
  if (title) console.log(c.dim(`  ${title}`));
}

function envAsk(question) {
  return askLine(question, {
    onEscape: "empty",
    onCtrlC: () => {
      console.log(`  Usá ${c.cyan("/exit")} para salir del entorno.`);
    },
  });
}

async function doCommit(session, message) {
  if (!hasAnyChanges() && !hasStagedChanges()) {
    console.log(c.yellow("  No hay cambios para commitear."));
    return;
  }

  if (!hasStagedChanges()) {
    console.log(c.dim("  Nada en el stage, agregando todos los cambios..."));
    if (!report(stageAll())) {
      console.log(c.red("  Falló git add."));
      return;
    }
  }

  if (!report(commit(applyPrefix(message, session.number)))) {
    console.log(c.red("  El commit falló."));
    return;
  }

  const raw = await envAsk(
    `  ¿Push a origin/${currentBranch()}? ${c.dim("[S/n]")} `,
  );
  const answer = (raw ?? "n").trim().toLowerCase();
  if (answer === "n" || answer === "no") {
    console.log(c.dim("  Commit local. Podés enviarlo después con /push."));
    return;
  }
  if (!report(push(), "Enviado.")) {
    console.log(c.red("  El push falló. Reintentá con /push."));
  }
}

/**
 * Consola del entorno. Queda abierta hasta /exit: cada línea que no sea un
 * comando se toma como mensaje de commit.
 * Devuelve "exit" o "switch" para que el CLI decida qué hacer.
 * No usa readline: en Git Bash eso rompe las flechas al volver al menú.
 */
export async function runEnvironment(session) {
  let action = "exit";

  console.log(c.dim("  Escribí un mensaje para commitear, o /help para ver los comandos."));
  console.log("");

  while (true) {
    printTitle(session);
    const line = await envAsk(promptFor(session));
    if (line === null) break;

    const value = line.trim();
    if (!value) continue;
    const lower = value.toLowerCase();

    if (lower === "/exit" || lower === "/salir" || lower === "exit" || lower === "salir") {
      break;
    }
    if (lower === "/help" || lower === "/ayuda" || lower === "?") {
      help();
      continue;
    }
    if (lower === "/status" || lower === "/st") {
      printBlock(shortStatus() || "Sin cambios.");
      continue;
    }
    if (lower === "/diff") {
      printBlock(diff().out || "Sin cambios.");
      continue;
    }
    if (lower === "/add") {
      stageAll();
      printBlock(shortStatus());
      continue;
    }
    if (lower === "/log") {
      printBlock(log().out || "Todavía no hay commits.");
      continue;
    }
    if (lower === "/push") {
      report(push(), "Enviado.");
      continue;
    }
    if (lower === "/pull") {
      report(pull());
      continue;
    }
    if (lower === "/issue") {
      action = "switch";
      break;
    }
    if (value.startsWith("!")) {
      const command = value.slice(1).trim();
      if (command) runShell(command);
      continue;
    }
    if (value.startsWith("/")) {
      console.log(c.yellow(`  Comando desconocido: ${value}. Probá /help.`));
      continue;
    }

    await doCommit(session, value);
  }

  if (action === "exit") {
    console.log("");
    console.log(
      c.dim(
        `  Saliste del entorno de #${session.number}. La sesión sigue activa (issue stop para cerrarla).`,
      ),
    );
  }
  return action;
}
