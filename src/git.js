import { execFileSync, spawnSync } from "node:child_process";

export function gitOut(args) {
  try {
    return execFileSync("git", args, {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    }).trim();
  } catch {
    return "";
  }
}

export function gitRun(args) {
  const result = spawnSync("git", args, { stdio: "inherit" });
  return result.status ?? 1;
}

function gitQuiet(args) {
  const result = spawnSync("git", args, { stdio: "ignore" });
  return result.status ?? 1;
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
  return gitRun(["add", "-A"]);
}

export function commit(message) {
  return gitRun(["commit", "-m", message]);
}

export function push() {
  if (hasUpstream()) {
    return gitRun(["push"]);
  }
  return gitRun(["push", "-u", "origin", currentBranch()]);
}
