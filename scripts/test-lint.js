import { lintLiquid } from "../src/lint-liquid.js";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.join(path.dirname(fileURLToPath(import.meta.url)), "..");
const ok = lintLiquid(
  fs.readFileSync(path.join(root, "examples/liquid/ok.tpl"), "utf8"),
  "ok.tpl",
);
const bad = lintLiquid(
  fs.readFileSync(path.join(root, "examples/liquid/bad-if.tpl"), "utf8"),
  "bad-if.tpl",
);

let failed = 0;
if (ok.length) {
  console.error("ok.tpl no debería tener errores:", ok);
  failed += 1;
}
if (!bad.length) {
  console.error("bad-if.tpl debería fallar y no falló.");
  failed += 1;
}
if (failed) process.exit(1);
console.log("lint fixtures OK");
