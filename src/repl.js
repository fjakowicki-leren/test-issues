import { spawnSync } from "node:child_process";
import {
  commit,
  currentBranch,
  hasAnyChanges,
  hasStagedChanges,
  push,
  stageAll,
} from "./git.js";
import { closeIssue } from "./github.js";
import { toggleHooksDisabled } from "./hooks.js";
import { formatLintErrors, lintAllLiquid } from "./lint-liquid.js";
import { applyDeployPrefix, applyPrefix, clearSession } from "./session.js";
import { askLine, c, clipTitle, printBlock, selectMenu } from "./ui.js";

function helpCommit() {
  console.log(`
  ${c.bold("Modo commit")} — el texto se toma como mensaje de commit.

  ${c.cyan("/dpy")}      commitea con ${c.bold("[deploy]")}   ${c.cyan("/shell")}    ir a modo shell
  ${c.cyan("/menu")}     ir al menú               ${c.cyan("/close")}    cerrar el issue activo
  ${c.cyan("/help")}     esta ayuda               ${c.cyan("/exit")}     salir del entorno
`);
}

function helpShell() {
  console.log(`
  ${c.bold("Modo shell")} — cada línea se ejecuta en la shell.

  ${c.cyan("/lint")}     test de sintaxis Liquid  ${c.cyan("/commit")}   ir a modo commit
  ${c.cyan("/menu")}     ir al menú               ${c.cyan("/exit")}     salir del entorno
  ${c.cyan("/help")}     esta ayuda
`);
}

function printLintResult({ files, errors }) {
  if (!files) {
    console.log(c.yellow("  No hay archivos .tpl / .liquid en el repo."));
    return;
  }
  if (!errors.length) {
    console.log(c.green(`  Sintaxis OK. ${files} archivo${files === 1 ? "" : "s"} sin errores.`));
    return;
  }
  console.log(
    c.red(
      `  ${errors.length} error${errors.length === 1 ? "" : "es"} en ${files} archivo${files === 1 ? "" : "s"}:`,
    ),
  );
  console.log("");
  printBlock(formatLintErrors(errors));
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

function promptFor(session, mode) {
  const tag = c.green(`[#${session.number}]`);
  if (mode === "shell") {
    return `${tag} ${c.cyan("shell")} ${c.dim("›")} `;
  }
  return `${tag} ${c.dim("›")} `;
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

async function doCommit(session, message, { deploy = false } = {}) {
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

  const text = deploy
    ? applyDeployPrefix(message, session.number)
    : applyPrefix(message, session.number);
  if (!report(commit(text))) {
    console.log(c.red("  El commit falló."));
    return;
  }

  const raw = await envAsk(
    `  ¿Push a origin/${currentBranch()}? ${c.dim("[S/n]")} `,
  );
  const answer = (raw ?? "n").trim().toLowerCase();
  if (answer === "n" || answer === "no") {
    console.log(c.dim("  Commit local. Para pushear, pasá a modo shell y corré git push."));
    return;
  }
  if (!report(push(), "Enviado.")) {
    console.log(c.red("  El push falló. Reintentá en modo shell con git push."));
  }
}

async function closeActiveIssue(session, { owner, repo }) {
  const ok = await selectMenu(`¿Cerrar ${c.green(`#${session.number}`)}?`, [
    { value: "yes", label: `Cerrar #${session.number}  ${session.title}` },
    { value: "no", label: "Cancelar" },
  ]);
  if (ok !== "yes") return null;
  console.log(c.dim(`  Cerrando #${session.number}...`));
  await closeIssue(owner, repo, session.number);
  clearSession();
  console.log(c.green(`  Cerrado #${session.number}  ${session.title}`));
  return "closed";
}

async function handleSharedCommand(lower, { session, owner, repo }) {
  if (lower === "/ldt") {
    const off = toggleHooksDisabled();
    console.log(c.dim(off ? "  Hooks desactivados." : "  Hooks activados."));
    return null;
  }
  if (lower === "/exit" || lower === "/salir" || lower === "exit" || lower === "salir") {
    return "exit";
  }
  if (lower === "/menu") return "switch";
  if (lower === "/close" || lower === "/cerrar") {
    return closeActiveIssue(session, { owner, repo });
  }
  return undefined;
}

async function runCommitMode(session, ctx) {
  printTitle(session);
  const line = await envAsk(promptFor(session, "commit"));
  if (line === null) return "exit";

  const value = line.trim();
  if (!value) return null;
  const lower = value.toLowerCase();

  if (lower === "/help" || lower === "/ayuda" || lower === "?") {
    helpCommit();
    return null;
  }
  if (lower === "/shell") return "mode:shell";
  const shared = await handleSharedCommand(lower, { session, ...ctx });
  if (shared !== undefined) return shared;

  if (lower === "/dpy" || lower.startsWith("/dpy ")) {
    const extra = value.slice("/dpy".length).trim();
    const message = extra || (await envAsk("  Mensaje del deploy: "));
    if (!message) {
      console.log(c.red("  El mensaje no puede estar vacío."));
      return null;
    }
    await doCommit(session, message, { deploy: true });
    return null;
  }
  if (value.startsWith("/")) {
    console.log(c.yellow(`  Comando desconocido: ${value}. Probá /help o /shell.`));
    return null;
  }

  await doCommit(session, value);
  return null;
}

async function runShellMode(session, ctx) {
  printTitle(session);
  const line = await envAsk(promptFor(session, "shell"));
  if (line === null) return "exit";

  const value = line.trim();
  if (!value) return null;
  const lower = value.toLowerCase();

  if (lower === "/help" || lower === "/ayuda" || lower === "?") {
    helpShell();
    return null;
  }
  if (lower === "/commit") return "mode:commit";
  if (lower === "/lint" || lower === "/syntax" || lower === "/sintaxis") {
    console.log(c.dim("  Revisando sintaxis Liquid de todos los archivos..."));
    printLintResult(lintAllLiquid());
    return null;
  }
  const shared = await handleSharedCommand(lower, { session, ...ctx });
  if (shared !== undefined) return shared;

  if (value.startsWith("/")) {
    console.log(c.yellow(`  Comando desconocido: ${value}. Probá /help o /commit.`));
    return null;
  }

  runShell(value);
  return null;
}

/**
 * Consola del entorno en modo commit o shell.
 * Devuelve "exit", "switch" o "closed".
 */
export async function runEnvironment(session, { owner, repo, mode = "commit" } = {}) {
  let action = "exit";
  let current = mode === "shell" ? "shell" : "commit";

  if (current === "shell") {
    console.log(c.dim("  Modo shell. Escribí un comando, /commit para commitear o /help."));
  } else {
    console.log(c.dim("  Modo commit. Escribí el mensaje, /shell para la terminal o /help."));
  }
  console.log("");

  while (true) {
    const result =
      current === "shell"
        ? await runShellMode(session, { owner, repo })
        : await runCommitMode(session, { owner, repo });

    if (result === "mode:shell") {
      current = "shell";
      console.log(c.dim("  Modo shell."));
      continue;
    }
    if (result === "mode:commit") {
      current = "commit";
      console.log(c.dim("  Modo commit."));
      continue;
    }
    if (result === "exit" || result === "switch" || result === "closed") {
      action = result;
      break;
    }
  }

  if (action === "exit") {
    console.log("");
    console.log(
      c.dim(
        `  Saliste del entorno de #${session.number}. La sesión sigue activa (leren-cli stop para cerrarla).`,
      ),
    );
  }
  return action;
}
