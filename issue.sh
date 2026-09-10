#!/usr/bin/env bash
# Entrada del entorno issue-env.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec node "$ROOT/bin/issue.js" "$@"
