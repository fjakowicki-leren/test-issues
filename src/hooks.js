import fs from "node:fs";
import path from "node:path";
import { repoRoot, resolveGitDir } from "./repo.js";

const HOOK_NAMES = ["pre-commit", "prepare-commit-msg", "commit-msg"];

function hookScript() {
  return `#!/bin/sh
# Instalado por leren-cli. Prefija commits y valida Liquid.
# En un clone de leren-cli usa src/ local; en una tienda delega al paquete canónico.
ROOT=$(git rev-parse --show-toplevel) || exit 1
HOOK=$(basename "$0")
if [ -f "$ROOT/src/git-hook.js" ] && [ -f "$ROOT/bin/leren-cli.js" ]; then
  exec node "$ROOT/src/git-hook.js" "$HOOK" "$@"
fi
if command -v leren-cli >/dev/null 2>&1; then
  exec leren-cli hook "$HOOK" "$@"
fi
exec npx --yes github:Leren-Dev/leren-cli hook "$HOOK" "$@"
`;
}

// En Windows el checkout deja CRLF (core.autocrlf), así que el fin de línea no cuenta como cambio:
// reescribirlo solo por eso ensuciaría el working tree.
const sameText = (a, b) => a.replace(/\r\n/g, "\n") === b.replace(/\r\n/g, "\n");

function writeIfChanged(file, content) {
  try {
    if (sameText(fs.readFileSync(file, "utf8"), content)) return false;
  } catch {
    // No existe o no se puede leer: se escribe igual.
  }
  fs.writeFileSync(file, content, { encoding: "utf8" });
  return true;
}

function hookOffPath() {
  return path.join(resolveGitDir(), "leren-cli-hooks-off");
}

export function areHooksDisabled() {
  return fs.existsSync(hookOffPath());
}

/** Toggle. Devuelve `true` si quedaron desactivados. */
export function toggleHooksDisabled() {
  const file = hookOffPath();
  if (fs.existsSync(file)) {
    fs.unlinkSync(file);
    return false;
  }
  fs.writeFileSync(file, `${new Date().toISOString()}\n`);
  return true;
}

export function installHooks({ tracked = false } = {}) {
  const hooksDir = path.join(resolveGitDir(), "hooks");
  fs.mkdirSync(hooksDir, { recursive: true });
  const installed = [];
  for (const name of HOOK_NAMES) {
    const dest = path.join(hooksDir, name);
    if (fs.existsSync(dest)) continue;
    fs.writeFileSync(dest, hookScript(), { encoding: "utf8" });
    try {
      fs.chmodSync(dest, 0o755);
    } catch {
      // Windows puede no soportar chmod; Git Bash igual ejecuta el shebang.
    }
    installed.push(name);
  }
  if (tracked) {
    const trackedDir = path.join(repoRoot(), ".githooks");
    fs.mkdirSync(trackedDir, { recursive: true });
    for (const name of HOOK_NAMES) {
      writeIfChanged(path.join(trackedDir, name), hookScript());
    }
  }
  return { all: HOOK_NAMES, installed };
}
