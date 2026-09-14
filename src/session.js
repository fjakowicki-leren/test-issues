import fs from "node:fs";
import path from "node:path";
import { resolveGitDir } from "./repo.js";

export function sessionPath() {
  const dir = resolveGitDir();
  const next = path.join(dir, "leren-cli.json");
  const prev = path.join(dir, "issue-env.json");
  return fs.existsSync(next) ? next : fs.existsSync(prev) ? prev : next;
}

export function readSession() {
  const file = sessionPath();
  if (!fs.existsSync(file)) return null;
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch {
    return null;
  }
}

export function writeSession(issue) {
  const number = Number(issue.number);
  const session = {
    number,
    title: issue.title,
    url: issue.html_url || issue.url,
    prefix: `[#${number}]`,
    startedAt: new Date().toISOString(),
  };
  const dest = path.join(resolveGitDir(), "leren-cli.json");
  fs.writeFileSync(dest, `${JSON.stringify(session, null, 2)}\n`);
  return session;
}

export function clearSession() {
  const dir = resolveGitDir();
  for (const name of ["leren-cli.json", "issue-env.json"]) {
    const file = path.join(dir, name);
    if (fs.existsSync(file)) fs.unlinkSync(file);
  }
}

export function prefixFor(number) {
  return `[#${number}]`;
}

function isGitCommentLine(line) {
  return /^\s*#/.test(line);
}

export function firstCommitLine(message) {
  return (
    String(message || "")
      .split(/\r?\n/)
      .find((line) => line.trim() && !isGitCommentLine(line)) || ""
  );
}

export function messageHasIssuePrefix(message, number) {
  const n = String(number);
  return new RegExp(`^\\s*\\[#${n}\\]`).test(firstCommitLine(message));
}

export function applyPrefix(message, number) {
  const prefix = prefixFor(number);
  if (messageHasIssuePrefix(message, number)) return message;
  const lines = String(message || "").split(/\r?\n/);
  const idx = lines.findIndex((line) => line.trim() && !isGitCommentLine(line));
  if (idx === -1) {
    return `${prefix} \n${message || ""}`;
  }
  lines[idx] = `${prefix} ${lines[idx].replace(/^\s+/, "")}`;
  return lines.join("\n");
}

export const DEPLOY_PREFIX = "[deploy]";

export function messageHasDeployPrefix(message) {
  return /\[deploy\]/i.test(firstCommitLine(message));
}

/** Deja el mensaje como `[#12] [deploy] resumen`. */
export function applyDeployPrefix(message, number) {
  const withIssue = applyPrefix(message, number);
  if (messageHasDeployPrefix(withIssue)) return withIssue;
  const lines = String(withIssue).split(/\r?\n/);
  const idx = lines.findIndex((line) => line.trim() && !isGitCommentLine(line));
  const issue = prefixFor(number);
  if (idx === -1) {
    return `${issue} ${DEPLOY_PREFIX} \n${withIssue}`;
  }
  const match = lines[idx].match(new RegExp(`^(\\s*\\[#${number}\\])\\s*`));
  const rest = match
    ? lines[idx].slice(match[0].length).replace(/^\s+/, "")
    : lines[idx].replace(/^\s+/, "");
  const head = match ? match[1] : issue;
  lines[idx] = rest ? `${head} ${DEPLOY_PREFIX} ${rest}` : `${head} ${DEPLOY_PREFIX}`;
  return lines.join("\n");
}
