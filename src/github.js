import { execFileSync } from "node:child_process";
import { resolveGh } from "./gh.js";

const API = "https://api.github.com";

function tokenFromGhCli() {
  try {
    const gh = resolveGh();
    if (!gh) return "";
    return execFileSync(gh, ["auth", "token"], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    }).trim();
  } catch {
    return "";
  }
}

export function githubToken() {
  return (
    process.env.GH_TOKEN ||
    process.env.GITHUB_TOKEN ||
    process.env.GH_ENTERPRISE_TOKEN ||
    tokenFromGhCli() ||
    ""
  );
}

function headers(token) {
  const h = {
    Accept: "application/vnd.github+json",
    "User-Agent": "leren-cli",
    "X-GitHub-Api-Version": "2022-11-28",
  };
  if (token) h.Authorization = `Bearer ${token}`;
  return h;
}

async function request(pathname, { method = "GET", body, token } = {}) {
  const auth = token ?? githubToken();
  const res = await fetch(`${API}${pathname}`, {
    method,
    headers: {
      ...headers(auth),
      ...(body ? { "Content-Type": "application/json" } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  let data = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = text;
  }
  if (!res.ok) {
    const msg = data?.message || text || res.statusText;
    const extra =
      res.status === 401 || res.status === 403
        ? " Autenticá con GH_TOKEN o `gh auth login`."
        : "";
    throw new Error(`GitHub API ${res.status}: ${msg}.${extra}`);
  }
  return data;
}

async function listIssues(owner, repo, { state, limit, sort = "created" }) {
  const issues = [];
  let page = 1;
  const perPage = Math.min(100, Math.max(limit || 100, 10));
  while (page <= 10 && (limit == null || issues.length < limit)) {
    const batch = await request(
      `/repos/${owner}/${repo}/issues?state=${state}&sort=${sort}&direction=desc&per_page=${perPage}&page=${page}`,
    );
    if (!Array.isArray(batch) || batch.length === 0) break;
    for (const item of batch) {
      if (item.pull_request) continue;
      if (state !== "all" && item.state !== state) continue;
      issues.push(item);
      if (limit != null && issues.length >= limit) break;
    }
    if (batch.length < perPage) break;
    page += 1;
  }
  return issues;
}

export function listOpenIssues(owner, repo) {
  return listIssues(owner, repo, { state: "open" });
}

export function listRecentIssues(owner, repo, limit = 10) {
  return listIssues(owner, repo, { state: "all", limit, sort: "updated" });
}

function requireToken(action) {
  const token = githubToken();
  if (!token) {
    throw new Error(
      `Para ${action} necesitás autenticación. Exportá GH_TOKEN o instalá GitHub CLI (\`gh auth login\`).`,
    );
  }
  return token;
}

export async function createIssue(owner, repo, { title, body }) {
  return request(`/repos/${owner}/${repo}/issues`, {
    method: "POST",
    body: { title, body: body || "" },
    token: requireToken("crear un issue"),
  });
}

export async function closeIssue(owner, repo, number) {
  return request(`/repos/${owner}/${repo}/issues/${number}`, {
    method: "PATCH",
    body: { state: "closed" },
    token: requireToken("cerrar un issue"),
  });
}
