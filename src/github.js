import { execFileSync } from "node:child_process";

const API = "https://api.github.com";

function tokenFromGhCli() {
  try {
    return execFileSync("gh", ["auth", "token"], {
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
    "User-Agent": "issue-env",
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

export async function listOpenIssues(owner, repo) {
  const issues = [];
  let page = 1;
  while (page <= 10) {
    const batch = await request(
      `/repos/${owner}/${repo}/issues?state=open&per_page=100&page=${page}`,
    );
    if (!Array.isArray(batch) || batch.length === 0) break;
    for (const item of batch) {
      if (!item.pull_request) issues.push(item);
    }
    if (batch.length < 100) break;
    page += 1;
  }
  return issues;
}

export async function createIssue(owner, repo, { title, body }) {
  const token = githubToken();
  if (!token) {
    throw new Error(
      "Para crear un issue necesitás autenticación. Exportá GH_TOKEN o instalá GitHub CLI (`gh auth login`).",
    );
  }
  return request(`/repos/${owner}/${repo}/issues`, {
    method: "POST",
    body: { title, body: body || "" },
    token,
  });
}
