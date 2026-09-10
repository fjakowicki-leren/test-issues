import { spawnSync } from "node:child_process";

const NOISE = [
  /^warning: (LF|CRLF) will be replaced by (CRLF|LF)/,
  /^The file will have its original line endings/,
];

function clean(text) {
  return String(text || "")
    .split(/\r?\n/)
    .filter((line) => !NOISE.some((re) => re.test(line)))
    .join("\n")
    .trim();
}

/**
 * Corre git capturando la salida. No heredamos la consola a propósito: en
 * Windows los binarios de git resetean el modo VT y a partir de ahí la
 * terminal imprime los códigos ANSI en crudo.
 */
export function git(args) {
  const result = spawnSync("git", args, { encoding: "utf8" });
  return {
    status: result.status ?? 1,
    out: clean(`${result.stdout || ""}${result.stderr || ""}`),
  };
}

export function gitOut(args) {
  return git(args).out;
}

function gitQuiet(args) {
  return spawnSync("git", args, { stdio: "ignore" }).status ?? 1;
}

export function currentBranch() {
  return gitOut(["rev-parse", "--abbrev-ref", "HEAD"]) || "HEAD";
}

export function shortStatus() {
  return gitOut(["status", "--short", "--branch"]);
}

export function hasAnyChanges() {
  return gitOut(["status", "--porcelain"]).length > 0;
}

export function hasStagedChanges() {
  return gitQuiet(["diff", "--cached", "--quiet"]) !== 0;
}

export function hasUpstream() {
  return gitQuiet(["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"]) === 0;
}

export function stageAll() {
  return git(["add", "-A"]);
}

export function commit(message) {
  return git(["commit", "-m", message]);
}

export function push() {
  if (hasUpstream()) return git(["push"]);
  return git(["push", "-u", "origin", currentBranch()]);
}

export function pull() {
  return git(["pull", "--ff-only"]);
}

export function log(count = 10) {
  return git(["--no-pager", "log", "--oneline", `-${count}`]);
}

export function diff() {
  return git(["--no-pager", "diff", "HEAD"]);
}
