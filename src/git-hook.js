#!/usr/bin/env node
import fs from "node:fs";
import { applyPrefix, firstCommitLine, messageHasIssuePrefix, readSession } from "./session.js";

const hook = process.argv[2];
const msgFile = process.argv[3];
const source = process.argv[4] || "";

function fail(message) {
  process.stderr.write(`\nissue-env: ${message}\n\n`);
  process.exit(1);
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
