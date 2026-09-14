#!/usr/bin/env node
import fs from "node:fs";
import { areHooksDisabled } from "./hooks.js";
import { formatLintErrors, lintStagedLiquid } from "./lint-liquid.js";
import { applyPrefix, firstCommitLine, messageHasIssuePrefix, readSession } from "./session.js";

const hook = process.argv[2];
const msgFile = process.argv[3];
const source = process.argv[4] || "";

function fail(message) {
  process.stderr.write(`\nissue-env: ${message}\n\n`);
  process.exit(1);
}

if (areHooksDisabled()) {
  process.exit(0);
}

if (hook === "pre-commit") {
  const { files, errors } = lintStagedLiquid();
  if (errors.length) {
    fail(
      `Hay ${errors.length} error${errors.length === 1 ? "" : "es"} de Liquid en ${files} archivo${files === 1 ? "" : "s"} en stage. El commit se canceló.\n\n${formatLintErrors(errors)}`,
    );
  }
  process.exit(0);
}

const session = readSession();
if (!session?.number) {
  fail(
    "No hay un issue activo. Antes de commitear corré: node bin/issue.js start",
  );
}

if (!msgFile) {
  fail("Hook de git invocado sin archivo de mensaje.");
}

const original = fs.readFileSync(msgFile, "utf8");
const prefixed = applyPrefix(original, session.number);
if (prefixed !== original) {
  fs.writeFileSync(msgFile, prefixed);
}

if (hook === "commit-msg") {
  const line = firstCommitLine(prefixed);
  if (!messageHasIssuePrefix(line, session.number) && !messageHasIssuePrefix(prefixed, session.number)) {
    fail(
      `El commit debe empezar con el prefijo ${session.prefix} (issue activo). Fuente: ${source || "editor"}`,
    );
  }
}
