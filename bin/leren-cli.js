#!/usr/bin/env node
import { main } from "../src/cli.js";

main(process.argv).catch((err) => {
  process.stderr.write(`\n${err.message || err}\n`);
  process.exit(1);
});
