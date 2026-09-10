import * as readline from "node:readline/promises";
import { stdin as input, stdout as output } from "node:process";

const c = {
  dim: (s) => `\x1b[2m${s}\x1b[0m`,
  bold: (s) => `\x1b[1m${s}\x1b[0m`,
  cyan: (s) => `\x1b[36m${s}\x1b[0m`,
  magenta: (s) => `\x1b[35m${s}\x1b[0m`,
  yellow: (s) => `\x1b[33m${s}\x1b[0m`,
  green: (s) => `\x1b[32m${s}\x1b[0m`,
  red: (s) => `\x1b[31m${s}\x1b[0m`,
};

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
    `  Issue activo: ${c.bold(`#${session.number}`)}  ${session.title}`,
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
