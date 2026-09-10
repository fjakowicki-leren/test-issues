import fs from "node:fs";
import path from "node:path";
import { resolveGitDir } from "./repo.js";

export function sessionPath() {
  return path.join(resolveGitDir(), "issue-env.json");
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
  fs.writeFileSync(sessionPath(), `${JSON.stringify(session, null, 2)}\n`);
  return session;
}

export function clearSession() {
  const file = sessionPath();
  if (fs.existsSync(file)) fs.unlinkSync(file);
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
