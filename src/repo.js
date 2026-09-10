import { execFileSync } from "node:child_process";
import path from "node:path";

export function git(args, options = {}) {
  return execFileSync("git", args, {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
    ...options,
  }).trim();
}

export function repoRoot() {
  try {
    return git(["rev-parse", "--show-toplevel"]);
  } catch {
    throw new Error("No estás dentro de un repositorio git.");
  }
}

export function gitDir() {
  try {
    return git(["rev-parse", "--git-dir"]);
  } catch {
    throw new Error("No estás dentro de un repositorio git.");
  }
}

export function resolveGitDir() {
  const dir = gitDir();
  return path.isAbsolute(dir) ? dir : path.join(repoRoot(), dir);
}

export function parseGithubRepo(remoteUrl) {
  const value = (remoteUrl || "").trim().replace(/\.git$/i, "");
  const https = value.match(/github\.com[/:]([^/]+)\/([^/]+)$/i);
  if (https) {
    return { owner: https[1], repo: https[2] };
  }
  throw new Error(
    `No pude reconocer un remoto de GitHub: ${remoteUrl || "(vacío)"}`,
  );
}

export function githubRepoFromOrigin() {
  let url;
  try {
    url = git(["remote", "get-url", "origin"]);
  } catch {
    throw new Error("No hay un remoto 'origin'. Configurá origin apuntando a GitHub.");
  }
  return parseGithubRepo(url);
}
