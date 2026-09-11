import { clearAuthMarker, ensureGhAuth } from "./gh.js";
import { createIssue, listOpenIssues, listRecentIssues } from "./github.js";
import { installHooks } from "./hooks.js";
import { githubRepoFromOrigin } from "./repo.js";
import { runEnvironment } from "./repl.js";
import { clearSession, readSession, writeSession } from "./session.js";
import {
  askLine,
  banner,
  c,
  formatIssueOption,
  printRecentIssues,
  printSession,
  selectMenu,
  withRawStdin,
} from "./ui.js";

function usage() {
  console.log(`
${c.bold("issue-env")} — consola de trabajo por issue de GitHub

  ${c.cyan("./issue.sh")}          Muestra los últimos 10 issues, obliga a elegir uno abierto o crear, abre la consola
  ${c.cyan("./issue.sh status")}   Muestra el issue activo
  ${c.cyan("./issue.sh stop")}     Cierra la sesión (los commits quedan bloqueados hasta elegir otro)
  ${c.cyan("./issue.sh login")}    Fuerza un nuevo gh auth login
  ${c.cyan("./issue.sh setup")}    Instala los hooks de git y actualiza la copia versionada en .githooks/

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

async function createIssueFlow({ owner, repo }) {
  const title = await askLine("  Título del issue: ");
  if (title == null) return undefined;
  if (!title) {
    console.log(c.red("  El título no puede estar vacío."));
    return undefined;
  }
  const body = await askLine("  Descripción (opcional): ");
  if (body == null) return undefined;
  console.log(c.dim("  Creando issue en GitHub..."));
  const created = await createIssue(owner, repo, { title, body });
  console.log(c.green(`  Creado ${created.html_url}`));
  return created;
}

async function pickOpenIssue(issues, { owner, repo }) {
  while (true) {
    const items = [
      ...issues.map((issue) => ({
        value: issue,
        label: formatIssueOption(issue),
      })),
      { value: "create", label: "Crear un issue nuevo" },
      { value: "cancel", label: "Cancelar" },
    ];
    const title = issues.length
      ? "Issues abiertos"
      : "No hay issues abiertos";
    const chosen = await selectMenu(title, items);
    if (chosen == null || chosen === "cancel") return null;
    if (chosen === "create") {
      const created = await createIssueFlow({ owner, repo });
      if (created) return created;
      continue;
    }
    return chosen;
  }
}

async function selectIssue(owner, repo) {
  return withRawStdin(async () => {
    let chosen = null;
    while (!chosen) {
      console.log(c.dim("  Cargando los 10 issues más recientes..."));
      printRecentIssues(await listRecentIssues(owner, repo, 10));
      const action = await selectMenu("¿Qué querés hacer?", [
        { value: "list", label: "Elegir de la lista" },
        { value: "create", label: "Crear un issue nuevo" },
        { value: "cancel", label: "Cancelar" },
      ]);
      if (action == null || action === "cancel") break;
      if (action === "create") {
        chosen = await createIssueFlow({ owner, repo });
        continue;
      }
      console.log(c.dim("  Cargando issues abiertos..."));
      const open = await listOpenIssues(owner, repo);
      chosen = await pickOpenIssue(open, { owner, repo });
    }
    if (!chosen) return null;

    const session = writeSession(chosen);
    console.log("");
    printSession(session);
    console.log("");
    return session;
  });
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

  await withRawStdin(async () => {
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
  });
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
  const names = installHooks({ tracked: true });
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
