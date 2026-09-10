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

export function installHooks() {
  const hooksDir = path.join(resolveGitDir(), "hooks");
  fs.mkdirSync(hooksDir, { recursive: true });
  for (const name of HOOK_NAMES) {
    const dest = path.join(hooksDir, name);
    fs.writeFileSync(dest, hookScript(), { encoding: "utf8" });
    try {
      fs.chmodSync(dest, 0o755);
    } catch {
      // Windows puede no soportar chmod; Git Bash igual ejecuta el shebang.
    }
  }
  // Copia versionada para el repo
  const tracked = path.join(repoRoot(), ".githooks");
  fs.mkdirSync(tracked, { recursive: true });
  for (const name of HOOK_NAMES) {
    fs.writeFileSync(path.join(tracked, name), hookScript(), { encoding: "utf8" });
  }
  return HOOK_NAMES;
}
