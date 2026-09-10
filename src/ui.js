import * as readline from "node:readline/promises";
import { stdin as input, stdout as output } from "node:process";

const useColor =
  Boolean(output.isTTY) && !process.env.NO_COLOR && process.env.TERM !== "dumb";

const paint = (code) => (s) =>
  useColor ? `\x1b[${code}m${s}\x1b[0m` : String(s);

const c = {
  dim: paint(2),
  bold: paint(1),
  cyan: paint(36),
  magenta: paint(35),
  yellow: paint(33),
  green: paint(32),
  red: paint(31),
};

export function clipTitle(title, max = 50) {
  const text = String(title || "").replace(/\s+/g, " ").trim();
  if (text.length <= max) return text;
  return `${text.slice(0, Math.max(0, max - 1))}…`;
}

/** Imprime la salida de un comando indentada al resto de la consola. */
export function printBlock(text) {
  const value = String(text || "").trim();
  if (!value) return;
  for (const line of value.split(/\r?\n/)) {
    console.log(`  ${line}`);
  }
}

export function banner(owner, repo) {
  console.log("");
  console.log(c.bold(c.magenta("  issue-env")) + c.dim("  ·  trabajo atado a un issue"));
  console.log(c.dim(`  ${owner}/${repo}`));
  console.log("");
}

export function printIssues(issues) {
  if (issues.length === 0) {
    console.log(c.yellow("  No hay issues abiertos."));
    console.log("");
    return;
  }
  console.log(c.bold("  Issues no cerrados:"));
  console.log("");
  for (let i = 0; i < issues.length; i += 1) {
    const issue = issues[i];
    const n = String(i + 1).padStart(2, " ");
    const labels = (issue.labels || [])
      .map((l) => (typeof l === "string" ? l : l.name))
      .filter(Boolean)
      .join(", ");
    console.log(
      `  ${c.cyan(n)}.  ${c.bold(`#${issue.number}`)}  ${issue.title}`,
    );
    if (labels) console.log(c.dim(`      ${labels}`));
  }
  console.log("");
}

export function printSession(session) {
  if (!session) {
    console.log(c.yellow("  No hay un issue activo. Corré `issue start`."));
    return;
  }
  console.log(
    `  Issue activo: ${c.bold(`#${session.number}`)}  ${clipTitle(session.title)}`,
  );
  console.log(`  Prefijo de commits: ${c.cyan(session.prefix)}`);
  if (session.url) console.log(c.dim(`  ${session.url}`));
}

export async function withRl(fn) {
  const rl = readline.createInterface({ input, output });
  try {
    return await fn(rl);
  } finally {
    rl.close();
  }
}

export async function ask(rl, question) {
  const answer = await rl.question(question);
  return answer.trim();
}

export { c };
