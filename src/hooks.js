import fs from "node:fs";
import path from "node:path";
import { repoRoot, resolveGitDir } from "./repo.js";

const HOOK_NAMES = ["prepare-commit-msg", "commit-msg"];

function hookScript() {
  return `#!/bin/sh
# Instalado por issue-env. Prefija commits con el issue activo.
ROOT=$(git rev-parse --show-toplevel) || exit 1
HOOK=$(basename "$0")
exec node "$ROOT/src/git-hook.js" "$HOOK" "$@"
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

export function installHooks({ tracked = false } = {}) {
  const hooksDir = path.join(resolveGitDir(), "hooks");
  fs.mkdirSync(hooksDir, { recursive: true });
  for (const name of HOOK_NAMES) {
    const dest = path.join(hooksDir, name);
    if (!writeIfChanged(dest, hookScript())) continue;
    try {
      fs.chmodSync(dest, 0o755);
    } catch {
      // Windows puede no soportar chmod; Git Bash igual ejecuta el shebang.
    }
  }
  if (tracked) {
    const trackedDir = path.join(repoRoot(), ".githooks");
    fs.mkdirSync(trackedDir, { recursive: true });
    for (const name of HOOK_NAMES) {
      writeIfChanged(path.join(trackedDir, name), hookScript());
    }
  }
  return HOOK_NAMES;
}
