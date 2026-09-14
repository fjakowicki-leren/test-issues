import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { repoRoot } from "./repo.js";

const LIQUID_EXT = /\.(tpl|liquid)$/i;

const BLOCKS = {
  if: "endif",
  for: "endfor",
  set: "endset",
  block: "endblock",
  embed: "endembed",
  macro: "endmacro",
};

const CLOSES = Object.fromEntries(
  Object.entries(BLOCKS).map(([open, close]) => [close, open]),
);

function lineAt(source, index) {
  return source.slice(0, index).split(/\n/).length;
}

function error(file, line, message) {
  return { file, line, message };
}

function skipString(src, i) {
  const quote = src[i];
  let n = i + 1;
  while (n < src.length) {
    if (src[n] === "\\") {
      n += 2;
      continue;
    }
    if (src[n] === quote) return n + 1;
    n += 1;
  }
  return -1;
}

function skipWs(src, i) {
  while (i < src.length && /\s/.test(src[i])) i += 1;
  return i;
}

function findClose(src, start, kind) {
  let i = start;
  let braceDepth = 0;
  while (i < src.length) {
    const ch = src[i];
    if (ch === "'" || ch === '"') {
      const next = skipString(src, i);
      if (next < 0) return { error: "string", at: i };
      i = next;
      continue;
    }
    if (ch === "{") {
      braceDepth += 1;
      i += 1;
      continue;
    }
    if (ch === "}") {
      if (braceDepth > 0) {
        braceDepth -= 1;
        i += 1;
        continue;
      }
      if (kind === "output" && src[i + 1] === "}") {
        return { innerEnd: i, closeEnd: i + 2 };
      }
    }
    if (kind === "output" && ch === "-" && src[i + 1] === "}" && src[i + 2] === "}" && braceDepth === 0) {
      return { innerEnd: i, closeEnd: i + 3 };
    }
    if (kind === "tag") {
      if (ch === "-" && src[i + 1] === "%" && src[i + 2] === "}" && braceDepth === 0) {
        return { innerEnd: i, closeEnd: i + 3 };
      }
      if (ch === "%" && src[i + 1] === "}" && braceDepth === 0) {
        return { innerEnd: i, closeEnd: i + 2 };
      }
    }
    i += 1;
  }
  return { error: "unclosed", at: start };
}

function lintBalance(text, file, line, where) {
  const errors = [];
  const stack = [];
  const openOf = { ")": "(", "]": "[", "}": "{" };
  const pairs = { "(": ")", "[": "]", "{": "}" };

  for (let i = 0; i < text.length; i += 1) {
    const ch = text[i];
    if (ch === "'" || ch === '"') {
      const next = skipString(text, i);
      if (next < 0) {
        errors.push(error(file, line, `String sin cerrar en ${where}.`));
        return errors;
      }
      i = next - 1;
      continue;
    }
    if (pairs[ch]) {
      stack.push(ch);
      continue;
    }
    if (openOf[ch]) {
      const expected = openOf[ch];
      if (!stack.length || stack[stack.length - 1] !== expected) {
        errors.push(
          error(file, line, `\`${ch}\` sin \`${expected}\` de apertura en ${where}.`),
        );
      } else {
        stack.pop();
      }
    }
  }

  for (const open of stack) {
    errors.push(
      error(file, line, `\`${open}\` sin \`${pairs[open]}\` de cierre en ${where}.`),
    );
  }
  return errors;
}

function lintSet(file, line, body) {
  const text = body.trim();
  if (!text) {
    return {
      error: error(
        file,
        line,
        "{% set %} vacío: falta `nombre = valor` o `{% set nombre %}...{% endset %}`.",
      ),
    };
  }
  const assign = text.match(/^([A-Za-z_][\w]*)\s*=\s*([\s\S]*)$/);
  if (assign) {
    const value = assign[2].trim();
    if (!value || /^[}\])]+$/.test(value)) {
      return {
        error: error(
          file,
          line,
          `{% set ${assign[1]} = %} sin valor a la derecha del \`=\`.`,
        ),
      };
    }
    return { kind: "assign", value: assign[2] };
  }
  if (/^[A-Za-z_][\w]*$/.test(text)) {
    return { kind: "block" };
  }
  return {
    error: error(
      file,
      line,
      `{% set %} inválido: usá \`{% set nombre = valor %}\` o \`{% set nombre %}...{% endset %}\`. Recibí: ${text.slice(0, 60)}`,
    ),
  };
}

function lintIf(file, line, body) {
  if (!body.trim()) return error(file, line, "{% if %} sin condición.");
  return null;
}

function lintFor(file, line, body) {
  const text = body.trim();
  if (!text) {
    return error(file, line, "{% for %} vacío: usá `{% for item in lista %}`.");
  }
  if (!/\bin\b/.test(text)) {
    return error(file, line, `{% for %} sin \`in\`: ${text.slice(0, 60)}`);
  }
  if (!/^\S+\s+in\s+\S/.test(text)) {
    return error(
      file,
      line,
      `{% for %} inválido: usá \`{% for item in lista %}\`. Recibí: ${text.slice(0, 60)}`,
    );
  }
  return null;
}

function firstName(body) {
  const match = String(body || "").trim().match(/^([A-Za-z_][\w]*)/);
  return match ? match[1] : "";
}

function closeLabel(type) {
  return BLOCKS[type] || `end${type}`;
}

export function lintLiquid(source, file = "template") {
  const errors = [];
  const stack = [];
  let i = 0;

  while (i < source.length) {
    if (source.startsWith("{#", i)) {
      const end = source.indexOf("#}", i + 2);
      if (end === -1) {
        errors.push(error(file, lineAt(source, i), "Comentario `{#` sin `#}`."));
        break;
      }
      i = end + 2;
      continue;
    }

    const isTag = source.startsWith("{%", i) || source.startsWith("{%-", i);
    const isOut = source.startsWith("{{", i) || source.startsWith("{{-", i);
    if (!isTag && !isOut) {
      i += 1;
      continue;
    }

    const kind = isTag ? "tag" : "output";
    const openLine = lineAt(source, i);
    let innerStart = i + 2;
    if (source[innerStart] === "-") innerStart += 1;
    innerStart = skipWs(source, innerStart);

    const closed = findClose(source, innerStart, kind);
    if (closed.error === "string") {
      errors.push(error(file, lineAt(source, closed.at), `String sin cerrar en ${kind === "tag" ? "{%%}" : "{{}}"}`));
      break;
    }
    if (closed.error) {
      errors.push(
        error(
          file,
          openLine,
          kind === "tag" ? "`{%` sin `%}` de cierre." : "`{{` sin `}}` de cierre.",
        ),
      );
      break;
    }

    const inner = source.slice(innerStart, closed.innerEnd);
    i = closed.closeEnd;

    if (kind === "output") {
      errors.push(...lintBalance(inner, file, openLine, "{{ }}"));
      continue;
    }

    const nameMatch = inner.match(/^([A-Za-z_]\w*)/);
    if (!nameMatch) {
      errors.push(error(file, openLine, "Tag `{% %}` sin nombre."));
      errors.push(...lintBalance(inner, file, openLine, "{% %}"));
      continue;
    }
    const name = nameMatch[1].toLowerCase();
    const body = inner.slice(nameMatch[1].length).trim();

    if (name === "comment") {
      const end = source.slice(i).search(/\{%-?\s*endcomment\s*-?%\}/i);
      if (end === -1) {
        errors.push(error(file, openLine, "{% comment %} sin {% endcomment %}."));
        break;
      }
      const close = source.slice(i).match(/\{%-?\s*endcomment\s*-?%\}/i);
      i += end + close[0].length;
      continue;
    }

    if (name === "set") {
      const result = lintSet(file, openLine, body);
      if (result.error) errors.push(result.error);
      else if (result.kind === "assign") {
        errors.push(...lintBalance(result.value, file, openLine, "{% set %}"));
      } else if (result.kind === "block") {
        stack.push({ type: "set", line: openLine });
      }
      continue;
    }

    if (body) {
      errors.push(...lintBalance(body, file, openLine, `{% ${name} %}`));
    }

    if (name === "if") {
      const err = lintIf(file, openLine, body);
      if (err) errors.push(err);
      stack.push({ type: "if", line: openLine, hasElse: false });
      continue;
    }

    if (name === "for") {
      const err = lintFor(file, openLine, body);
      if (err) errors.push(err);
      stack.push({ type: "for", line: openLine });
      continue;
    }

    if (name === "block") {
      const blockName = firstName(body);
      if (!blockName) {
        errors.push(error(file, openLine, "{% block %} sin nombre."));
      }
      stack.push({ type: "block", line: openLine, name: blockName });
      continue;
    }

    if (name === "embed") {
      if (!body.trim()) {
        errors.push(error(file, openLine, "{% embed %} sin template."));
      }
      stack.push({ type: "embed", line: openLine });
      continue;
    }

    if (name === "macro") {
      if (!/^[A-Za-z_][\w]*\s*\(/.test(body)) {
        errors.push(
          error(file, openLine, "{% macro %} inválido: usá `{% macro nombre() %}`."),
        );
      }
      stack.push({ type: "macro", line: openLine });
      continue;
    }

    if (name === "elsif" || name === "elseif") {
      const open = [...stack].reverse().find((f) => f.type === "if");
      if (!open) {
        errors.push(error(file, openLine, `{% ${name} %} sin un {% if %} abierto.`));
      } else if (open.hasElse) {
        errors.push(error(file, openLine, `{% ${name} %} después de {% else %}.`));
      } else if (!body.trim()) {
        errors.push(error(file, openLine, `{% ${name} %} sin condición.`));
      }
      continue;
    }

    if (name === "else") {
      const open = [...stack].reverse().find((f) => f.type === "if");
      if (!open) {
        errors.push(error(file, openLine, "{% else %} sin un {% if %} abierto."));
      } else if (open.hasElse) {
        errors.push(error(file, openLine, "{% else %} duplicado para el mismo {% if %}."));
      } else {
        open.hasElse = true;
      }
      continue;
    }

    const opens = CLOSES[name];
    if (opens) {
      const top = stack[stack.length - 1];
      if (!top) {
        errors.push(error(file, openLine, `{% ${name} %} sin un {% ${opens} %} abierto.`));
      } else if (top.type !== opens) {
        errors.push(
          error(
            file,
            openLine,
            `{% ${name} %} cierra un {% ${top.type} %} abierto en la línea ${top.line}.`,
          ),
        );
      } else {
        if (name === "endblock" && body && top.name && firstName(body) !== top.name) {
          errors.push(
            error(
              file,
              openLine,
              `{% endblock ${firstName(body)} %} no coincide con {% block ${top.name} %} (línea ${top.line}).`,
            ),
          );
        }
        stack.pop();
      }
    }
  }

  for (const open of stack) {
    errors.push(
      error(
        file,
        open.line,
        `{% ${open.type}${open.name ? ` ${open.name}` : ""} %} sin {% ${closeLabel(open.type)} %} que lo cierre.`,
      ),
    );
  }

  return errors;
}

export function isLiquidFile(file) {
  return LIQUID_EXT.test(file);
}

function isLintFixture(file) {
  const posix = file.split(path.sep).join("/");
  return posix === "examples" || posix.startsWith("examples/");
}

function stagedLiquidFiles() {
  const result = spawnSync(
    "git",
    ["diff", "--cached", "--name-only", "--diff-filter=ACMR"],
    { encoding: "utf8" },
  );
  if (result.status !== 0) return [];
  return String(result.stdout || "")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((file) => file && isLiquidFile(file) && !isLintFixture(file));
}

function stagedContent(file) {
  const posix = file.split(path.sep).join("/");
  const result = spawnSync("git", ["show", `:${posix}`], { encoding: "utf8" });
  if (result.status !== 0) return null;
  return result.stdout;
}

export function lintStagedLiquid() {
  const files = stagedLiquidFiles();
  const errors = [];
  for (const file of files) {
    const content = stagedContent(file);
    if (content == null) continue;
    errors.push(...lintLiquid(content, file));
  }
  return { files: files.length, errors };
}

function walkLiquidFiles(dir, acc = []) {
  let entries = [];
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return acc;
  }
  for (const entry of entries) {
    if (entry.name === ".git" || entry.name === "node_modules" || entry.name === "examples") continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walkLiquidFiles(full, acc);
    else if (isLiquidFile(entry.name)) acc.push(full);
  }
  return acc;
}

/** Revisa todos los `.tpl` / `.liquid` del repo (working tree), no solo el stage. */
export function lintAllLiquid() {
  const root = repoRoot();
  const files = walkLiquidFiles(root);
  const errors = [];
  for (const abs of files) {
    const rel = path.relative(root, abs).split(path.sep).join("/");
    let content;
    try {
      content = fs.readFileSync(abs, "utf8");
    } catch {
      continue;
    }
    errors.push(...lintLiquid(content, rel));
  }
  return { files: files.length, errors };
}

export function formatLintErrors(errors) {
  return errors
    .map((err) => `  ${err.file}:${err.line}  ${err.message}`)
    .join("\n");
}
