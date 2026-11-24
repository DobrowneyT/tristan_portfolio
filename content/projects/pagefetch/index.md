---
title: "pagefetch"
subtitle: "A real browser as a service, for AI agents"
date: 2026-08-16
period: "August 2026"
weight: 50
status: stub
context: "Personal project"
role: "Everything: spec, design, implementation, deployment"
summary: "A self-hosted service that fetches web pages a plain HTTP request can't, by driving Chromium in Docker. It speaks MCP and HTTP and respects robots.txt."
stack: ["TypeScript", "Docker", "Chromium", "MCP", "SQLite"]
links:
  - { name: "GitHub", url: "https://github.com/DobrowneyT/pagefetch" }
---
A plain HTTP request fails on many modern pages for three different reasons: the content is rendered by JavaScript, the route lives after a `#` that never leaves the browser, or the site refuses anything that isn't a browser. A real browser handles all three just by being a browser.

pagefetch runs Chromium inside its own Docker container on a VPS. It serves pages to AI agents over both MCP and plain HTTP, with `robots.txt` enforced by default, a SQLite cache, and per-site politeness limits enforced on the server. I wrote it as a spec first, then built it with Claude Code, and measured which sites it can actually reach instead of assuming.
