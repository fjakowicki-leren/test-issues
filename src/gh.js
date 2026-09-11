import fs from "node:fs";
import path from "node:path";
import { execFileSync, spawn } from "node:child_process";
import { resolveGitDir } from "./repo.js";

let resolvedGh = undefined;

function fallbackGhPaths() {
  const local = process.env.LOCALAPPDATA;
  return [
    "C:\\Program Files\\GitHub CLI\\gh.exe",
    "C:\\Program Files (x86)\\GitHub CLI\\gh.exe",
    local ? path.join(local, "Programs", "GitHub CLI", "gh.exe") : "",
  ].filter(Boolean);
}

/** Ruta a `gh`. Tras un install de winget el PATH de la terminal actual suele no actualizarse. */
export function resolveGh() {
  if (resolvedGh !== undefined) return resolvedGh;

  for (const candidate of fallbackGhPaths()) {
    if (fs.existsSync(candidate)) {
      resolvedGh = candidate;
      return resolvedGh;
    }
  }

  for (const name of process.platform === "win32" ? ["gh.exe", "gh"] : ["gh"]) {
    try {
      execFileSync(name, ["--version"], { stdio: "ignore" });
      resolvedGh = name;
      return resolvedGh;
    } catch {
      // Sigue con el siguiente candidato.
    }
  }

  resolvedGh = null;
  return resolvedGh;
}

function ghBin() {
  const bin = resolveGh();
  if (!bin) throw new Error(missingGhMessage());
  return bin;
}

function authMarkerPath() {
  return path.join(resolveGitDir(), "issue-env-auth.json");
}

export function readAuthMarker() {
  const file = authMarkerPath();
  if (!fs.existsSync(file)) return null;
  try {
    const marker = JSON.parse(fs.readFileSync(file, "utf8"));
    return marker?.host ? marker : null;
  } catch {
    return null;
  }
}

export function writeAuthMarker(user) {
  const marker = {
    host: "github.com",
    user: user || "",
    at: new Date().toISOString(),
  };
  fs.writeFileSync(authMarkerPath(), `${JSON.stringify(marker, null, 2)}\n`);
  return marker;
}

export function clearAuthMarker() {
  const file = authMarkerPath();
  if (fs.existsSync(file)) fs.unlinkSync(file);
}

export function ghAvailable() {
  return Boolean(resolveGh());
}

export function ghAuthStatus() {
  try {
    const out = execFileSync(ghBin(), ["auth", "status", "--hostname", "github.com"], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    });
    return { ok: true, user: parseUser(out) };
  } catch (err) {
    const out = `${err.stdout || ""}${err.stderr || ""}`;
    if (/Logged in to/i.test(out)) {
      return { ok: true, user: parseUser(out) };
    }
    return { ok: false, user: "" };
  }
}

function parseUser(output) {
  const match = String(output || "").match(
    /Logged in to \S+ (?:as|account) (\S+)/i,
  );
  return match ? match[1] : "";
}

function ghAuthLogin() {
  return new Promise((resolve, reject) => {
    const child = spawn(ghBin(), ["auth", "login", "--hostname", "github.com"], {
      stdio: "inherit",
    });
    child.on("exit", (code) => {
      if (code === 0) resolve();
      else {
        reject(
          new Error(
            `gh auth login terminó con código ${code}. Sin autenticación no se puede iniciar.`,
          ),
        );
      }
    });
    child.on("error", (err) => {
      if (err.code === "ENOENT") {
        reject(new Error(missingGhMessage()));
        return;
      }
      reject(err);
    });
  });
}

function missingGhMessage() {
  return "No está instalado GitHub CLI (gh). Instalalo desde https://cli.github.com/ (Windows: winget install --id GitHub.cli) y volvé a correr issue start.";
}

/**
 * Autentica una sola vez por entorno: si ya hay marca local, no vuelve a
 * consultar ni a pedir login. Con `force` siempre corre `gh auth login`.
 */
export async function ensureGhAuth({ force = false } = {}) {
  if (!ghAvailable()) {
    throw new Error(missingGhMessage());
  }

  if (!force) {
    const marker = readAuthMarker();
    if (marker) {
      return { state: "cached", user: marker.user };
    }
    const status = ghAuthStatus();
    if (status.ok) {
      writeAuthMarker(status.user);
      return { state: "already", user: status.user };
    }
  }

  await ghAuthLogin();
  const status = ghAuthStatus();
  if (!status.ok) {
    throw new Error("gh auth login no dejó una sesión activa. Reintentá.");
  }
  writeAuthMarker(status.user);
  return { state: "logged-in", user: status.user };
}
