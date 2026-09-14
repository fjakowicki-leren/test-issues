import * as readline from "node:readline/promises";
import { stdin as input, stdout as output } from "node:process";

const useColor =
  Boolean(output.isTTY) && !process.env.NO_COLOR && process.env.TERM !== "dumb";

const paint = (code) => (s) =>
  useColor ? `\x1b[${code}m${s}\x1b[0m` : String(s);

const c = {
  dim: paint(2),
  bold: paint(1),
  cyan: paint(36),
  magenta: paint(35),
  yellow: paint(33),
  green: paint(32),
  red: paint(31),
};

export function clipTitle(title, max = 50) {
  const text = String(title || "").replace(/\s+/g, " ").trim();
  if (text.length <= max) return text;
  return `${text.slice(0, Math.max(0, max - 1))}…`;
}

/** Imprime la salida de un comando indentada al resto de la consola. */
export function printBlock(text) {
  const value = String(text || "").trim();
  if (!value) return;
  for (const line of value.split(/\r?\n/)) {
    console.log(`  ${line}`);
  }
}

export function banner(owner, repo) {
  console.log("");
  console.log(c.bold(c.magenta("  leren-cli")) + c.dim("  ·  trabajo atado a un issue"));
  console.log(c.dim(`  ${owner}/${repo}`));
  console.log("");
}

function issueLabels(issue) {
  return (issue.labels || [])
    .map((l) => (typeof l === "string" ? l : l.name))
    .filter(Boolean)
    .join(", ");
}

function issueNumber(issue) {
  const text = `#${issue.number}`;
  return issue.state === "open" ? c.green(c.bold(text)) : c.magenta(c.bold(text));
}

export function printRecentIssues(issues) {
  if (issues.length === 0) {
    console.log(c.yellow("  No hay issues en el repo."));
    console.log("");
    return;
  }
  console.log(c.bold(`  Últimos ${issues.length} issues más recientes:`));
  console.log("");
  for (const issue of issues) {
    const labels = issueLabels(issue);
    console.log(
      `      ${issueNumber(issue)}  ${issue.title}`,
    );
    if (labels) console.log(c.dim(`          ${labels}`));
  }
  console.log("");
}

export function printIssues(issues) {
  if (issues.length === 0) {
    console.log(c.yellow("  No hay issues abiertos."));
    console.log("");
    return;
  }
  console.log(c.bold("  Issues abiertos:"));
  console.log("");
  for (let i = 0; i < issues.length; i += 1) {
    const issue = issues[i];
    const n = String(i + 1).padStart(2, " ");
    const labels = issueLabels(issue);
    console.log(
      `  ${c.cyan(n)}.  ${issueNumber(issue)}  ${issue.title}`,
    );
    if (labels) console.log(c.dim(`      ${labels}`));
  }
  console.log("");
}

export function formatIssueOption(issue) {
  const labels = issueLabels(issue);
  const extra = labels ? c.dim(`  ${labels}`) : "";
  return `${issueNumber(issue)}  ${issue.title}${extra}`;
}

const MENU_WINDOW = 12;

function countLines(text) {
  return text.replace(/\n$/, "").split("\n").length;
}

function canUseInteractiveMenu() {
  return Boolean(
    input.isTTY && output.isTTY && typeof input.setRawMode === "function",
  );
}

let rawDepth = 0;
let rawWas = false;
let keyBuf = "";
let keyWaiter = null;
let escapeTimer = null;
let rawDataBound = false;

function takeKey(buf) {
  if (!buf) return { wait: false, key: null, rest: buf };
  if (buf[0] === "\r") {
    return { key: "enter", rest: buf[1] === "\n" ? buf.slice(2) : buf.slice(1) };
  }
  if (buf[0] === "\n") return { key: "enter", rest: buf.slice(1) };
  if (buf[0] === "\x03") return { key: "ctrl-c", rest: buf.slice(1) };
  if (buf[0] === "\x1b") {
    if (buf.length === 1) return { wait: true, rest: buf };
    if (buf[1] === "[" || buf[1] === "O") {
      let i = 2;
      while (i < buf.length && buf[i] >= "0" && buf[i] <= "?") i += 1;
      if (i >= buf.length) return { wait: true, rest: buf };
      const seq = buf.slice(0, i + 1);
      const rest = buf.slice(i + 1);
      if (seq.endsWith("A")) return { key: "up", rest };
      if (seq.endsWith("B")) return { key: "down", rest };
      return { key: null, rest };
    }
    return { key: "escape", rest: buf.slice(1) };
  }
  const ch = buf[0];
  const rest = buf.slice(1);
  if (ch === "\x7f" || ch === "\b") return { key: "backspace", rest };
  if (ch >= " ") return { key: "char", char: ch, rest };
  return { key: null, rest };
}

function flushKeys() {
  if (escapeTimer) {
    clearTimeout(escapeTimer);
    escapeTimer = null;
  }
  while (keyWaiter) {
    const taken = takeKey(keyBuf);
    keyBuf = taken.rest;
    if (taken.wait) {
      escapeTimer = setTimeout(() => {
        escapeTimer = null;
        if (keyBuf.startsWith("\x1b") && keyWaiter) {
          keyBuf = keyBuf.slice(1);
          const resolve = keyWaiter;
          keyWaiter = null;
          resolve({ name: "escape" });
        }
      }, 250);
      return;
    }
    if (taken.key != null) {
      const resolve = keyWaiter;
      keyWaiter = null;
      resolve(taken.key === "char" ? { name: "char", char: taken.char } : { name: taken.key });
      return;
    }
    if (!keyBuf) return;
  }
}

function onRawData(chunk) {
  keyBuf += String(chunk);
  flushKeys();
}

function bindRawData() {
  if (rawDataBound) return;
  input.on("data", onRawData);
  rawDataBound = true;
}

function unbindRawData() {
  if (!rawDataBound) return;
  input.off("data", onRawData);
  rawDataBound = false;
  if (escapeTimer) {
    clearTimeout(escapeTimer);
    escapeTimer = null;
  }
  keyBuf = "";
  keyWaiter = null;
}

export async function withRawStdin(fn) {
  if (!canUseInteractiveMenu()) return fn();
  if (rawDepth === 0) {
    rawWas = Boolean(input.isRaw);
    input.setEncoding("utf8");
    input.setRawMode(true);
    input.resume();
    bindRawData();
  }
  rawDepth += 1;
  try {
    return await fn();
  } finally {
    rawDepth -= 1;
    if (rawDepth === 0) {
      output.write("\x1b[?25h");
      unbindRawData();
      input.setRawMode(rawWas);
    }
  }
}

async function discardPendingKeys() {
  keyBuf = "";
  await new Promise((resolve) => setTimeout(resolve, 20));
  keyBuf = "";
}

function readRawKey() {
  return new Promise((resolve) => {
    keyWaiter = resolve;
    flushKeys();
  });
}

function menuWindow(length, index, size) {
  if (length <= size) return { start: 0, end: length };
  const start = Math.max(0, Math.min(index - Math.floor(size / 2), length - size));
  return { start, end: start + size };
}

function renderMenu(title, items, index) {
  const lines = [];
  if (title) {
    lines.push(c.bold(`  ${title}`));
    lines.push("");
  }
  const { start, end } = menuWindow(items.length, index, MENU_WINDOW);
  if (start > 0) lines.push(c.dim("    ↑  más"));
  for (let i = start; i < end; i += 1) {
    const selected = i === index;
    const pointer = selected ? c.cyan("❯") : " ";
    const raw = items[i].label;
    const label = selected && !raw.includes("\x1b") ? c.bold(raw) : raw;
    lines.push(`  ${pointer} ${label}`);
  }
  if (end < items.length) lines.push(c.dim("    ↓  más"));
  lines.push("");
  lines.push(c.dim("  ↑↓ mover   Enter elegir   q cancelar"));
  return `${lines.join("\n")}\n`;
}

async function selectMenuFallback(title, items) {
  return withRl(async (rl) => {
    if (title) {
      console.log(c.bold(`  ${title}`));
      console.log("");
    }
    for (let i = 0; i < items.length; i += 1) {
      console.log(`  ${c.cyan(String(i + 1))}.  ${items[i].label}`);
    }
    console.log("");
    while (true) {
      const answer = (await ask(rl, "  Elegí una opción: ")).toLowerCase();
      if (answer === "q" || answer === "quit" || answer === "salir") return null;
      const n = Number.parseInt(answer, 10);
      if (Number.isInteger(n) && n >= 1 && n <= items.length) {
        return items[n - 1].value;
      }
      console.log(c.red("  Opción inválida."));
    }
  });
}

async function runSelectMenu(title, items) {
  await discardPendingKeys();
  let index = 0;
  let drawn = 0;
  const draw = () => {
    const text = renderMenu(title, items, index);
    if (drawn > 0) output.write(`\x1b[${drawn}A\x1b[0J`);
    output.write(text);
    drawn = countLines(text);
  };

  output.write("\x1b[?25l");
  draw();

  try {
    while (true) {
      const key = await readRawKey();
      if (key.name === "ctrl-c") {
        output.write("\x1b[?25h\n");
        process.exit(130);
      }
      if (key.name === "escape" || (key.name === "char" && (key.char === "q" || key.char === "Q"))) {
        return null;
      }
      if (key.name === "up" || (key.name === "char" && (key.char === "k" || key.char === "K"))) {
        index = (index - 1 + items.length) % items.length;
        draw();
        continue;
      }
      if (key.name === "down" || (key.name === "char" && (key.char === "j" || key.char === "J"))) {
        index = (index + 1) % items.length;
        draw();
        continue;
      }
      if (key.name === "enter") return items[index].value;
    }
  } finally {
    output.write("\x1b[?25h\n");
  }
}

/** Menú con flechas. Sin TTY cae a elegir por número. `q` / Esc devuelve `null`. */
export async function selectMenu(title, items) {
  if (!items.length) return null;
  if (!canUseInteractiveMenu()) return selectMenuFallback(title, items);
  return withRawStdin(() => runSelectMenu(title, items));
}

export function printSession(session) {
  if (!session) {
    console.log(c.yellow("  No hay un issue activo. Corré `leren-cli`."));
    return;
  }
  console.log(
    `  Issue activo: ${c.green(c.bold(`#${session.number}`))}  ${c.green(clipTitle(session.title))}`,
  );
  console.log(`  Prefijo de commits: ${c.cyan(session.prefix)}`);
  if (session.url) console.log(c.dim(`  ${session.url}`));
}

export async function withRl(fn) {
  const rl = readline.createInterface({ input, output });
  try {
    return await fn(rl);
  } finally {
    rl.close();
  }
}

export async function ask(rl, question) {
  const answer = await rl.question(question);
  return answer.trim();
}

async function askRaw(question, { onEscape = "null", onCtrlC = "exit" } = {}) {
  await discardPendingKeys();
  output.write("\x1b[?25h");
  output.write(question);
  let value = "";
  while (true) {
    const key = await readRawKey();
    if (key.name === "ctrl-c") {
      output.write("\n");
      if (typeof onCtrlC === "function") {
        onCtrlC();
        return "";
      }
      if (onCtrlC === "empty") return "";
      process.exit(130);
    }
    if (key.name === "escape") {
      output.write("\n");
      return onEscape === "empty" ? "" : null;
    }
    if (key.name === "enter") {
      output.write("\n");
      return value.trim();
    }
    if (key.name === "backspace") {
      if (!value) continue;
      value = value.slice(0, -1);
      output.write("\b \b");
      continue;
    }
    if (key.name === "char") {
      value += key.char;
      output.write(key.char);
    }
  }
}

/** Pregunta en raw mode para no soltar el TTY (readline rompe las flechas en Git Bash). */
export async function askLine(question, opts) {
  if (rawDepth > 0) return askRaw(question, opts);
  return withRl((rl) => ask(rl, question));
}

export { c };
