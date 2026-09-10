import { clearAuthMarker, ensureGhAuth } from "./gh.js";
import { createIssue, listOpenIssues } from "./github.js";
import { installHooks } from "./hooks.js";
import { githubRepoFromOrigin } from "./repo.js";
import { runEnvironment } from "./repl.js";
import { clearSession, readSession, writeSession } from "./session.js";
import {
  ask,
  banner,
  c,
  printIssues,
  printSession,
  withRl,
} from "./ui.js";

function usage() {
  console.log(`
${c.bold("issue-env")} — consola de trabajo por issue de GitHub

  ${c.cyan("./issue.sh")}          Lista issues abiertos, obliga a elegir o crear uno, abre la consola
  ${c.cyan("./issue.sh status")}   Muestra el issue activo
  ${c.cyan("./issue.sh stop")}     Cierra la sesión (los commits quedan bloqueados hasta elegir otro)
  ${c.cyan("./issue.sh login")}    Fuerza un nuevo gh auth login
  ${c.cyan("./issue.sh setup")}    Instala los hooks de git (también ocurre en start)

El login de GitHub se hace una sola vez por entorno y queda cacheado.
Sin issue activo no se puede hacer commit. El mensaje queda como: ${c.bold("[#12] resumen")}
`);
}

function printAuth({ state, user }) {
  const who = user ? ` (${user})` : "";
  if (state === "cached") {
    console.log(c.dim(`  GitHub CLI: sesión ya inicializada en este entorno${who}.`));
  } else if (state === "already") {
    console.log(c.green(`  GitHub CLI: sesión activa${who}.`));
  } else {
    console.log(c.green(`  GitHub CLI: login correcto${who}.`));
  }
}

async function pickIssue(issues, { owner, repo }) {
  return withRl(async (rl) => {
    while (true) {
      console.log(c.bold("  Tenés que elegir un issue para trabajar."));
      console.log(`  ${c.cyan("n")}  crear un issue nuevo`);
      if (issues.length > 0) {
        console.log(`  ${c.cyan("1")}-${c.cyan(String(issues.length))}  usar uno de la lista`);
      }
      console.log(`  ${c.cyan("q")}  cancelar`);
      console.log("");
      const answer = (await ask(rl, "  Elegí una opción: ")).toLowerCase();
      if (answer === "q" || answer === "quit" || answer === "salir") {
        return null;
      }
      if (answer === "n" || answer === "nuevo" || answer === "new") {
        const title = await ask(rl, "  Título del issue: ");
        if (!title) {
          console.log(c.red("  El título no puede estar vacío."));
          continue;
        }
        const body = await ask(rl, "  Descripción (opcional): ");
        console.log(c.dim("  Creando issue en GitHub..."));
        const created = await createIssue(owner, repo, { title, body });
        console.log(c.green(`  Creado ${created.html_url}`));
        return created;
      }
      const index = Number.parseInt(answer, 10);
      if (Number.isInteger(index) && index >= 1 && index <= issues.length) {
        return issues[index - 1];
      }
      console.log(c.red("  Opción inválida. Es obligatorio elegir o crear un issue."));
      console.log("");
    }
  });
}

async function selectIssue(owner, repo) {
  console.log(c.dim("  Cargando issues abiertos..."));
  const issues = await listOpenIssues(owner, repo);
  printIssues(issues);

  const chosen = await pickIssue(issues, { owner, repo });
  if (!chosen) return null;

  const session = writeSession(chosen);
  console.log("");
  printSession(session);
  console.log("");
  return session;
}

async function cmdStart() {
  const { owner, repo } = githubRepoFromOrigin();
  banner(owner, repo);
  installHooks();

  printAuth(await ensureGhAuth());
  console.log("");

  const current = readSession();
  if (current) {
    console.log(c.dim("  Sesión previa:"));
    printSession(current);
    console.log("");
  }

  let session = await selectIssue(owner, repo);
  if (!session) {
    console.log("");
    console.log(c.yellow("  No se activó ningún issue. Los commits seguirán bloqueados."));
    process.exitCode = 1;
    return;
  }

  while (session) {
    const action = await runEnvironment(session);
    if (action !== "switch") break;
    console.log("");
    const next = await selectIssue(owner, repo);
    if (!next) {
      console.log(c.dim(`  Seguís en #${session.number}.`));
      continue;
    }
    session = next;
  }
}

function cmdStatus() {
  const { owner, repo } = githubRepoFromOrigin();
  banner(owner, repo);
  printSession(readSession());
  console.log("");
}

function cmdStop() {
  const current = readSession();
  clearSession();
  if (current) {
    console.log(`  Cerrada la sesión de ${c.bold(`#${current.number}`)}.`);
    console.log(c.yellow("  Los próximos commits quedan bloqueados hasta iniciar de nuevo."));
  } else {
    console.log("  No había una sesión activa.");
  }
}

async function cmdLogin() {
  clearAuthMarker();
  printAuth(await ensureGhAuth({ force: true }));
}

function cmdSetup() {
  const names = installHooks();
  console.log(`  Hooks instalados: ${names.join(", ")}`);
}

export async function main(argv) {
  const args = argv.slice(2);
  const positional = args.filter((a) => !a.startsWith("-"));
  const cmd = positional[0] || "start";

  if (cmd === "-h" || cmd === "--help" || cmd === "help") {
    usage();
    return;
  }

  if (cmd === "start") return cmdStart();
  if (cmd === "status") return cmdStatus();
  if (cmd === "stop") return cmdStop();
  if (cmd === "login") return cmdLogin();
  if (cmd === "setup") return cmdSetup();

  console.error(`Comando desconocido: ${cmd}`);
  usage();
  process.exitCode = 1;
}
