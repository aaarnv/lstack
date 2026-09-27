# NOTICE

lstack is LyraLink's fork of [pstack-claude v0.9.30](https://github.com/michael-denyer/pstack-claude/tree/v0.9.30) (MIT). It lives at `plugins/lstack/` in the LyraLink repository.

## Credits

- **Lauren Tan (poteto)** wrote the original [pstack](https://github.com/cursor/plugins/tree/main/pstack): poteto-mode, the principles, and most skills. (c) 2026 Lauren Tan, MIT, see [LICENSE](LICENSE).
- **Michael Denyer** ported pstack to Claude Code as [pstack-claude](https://github.com/michael-denyer/pstack-claude) and authored `babysit`, the hooks, and the port changes listed below.
- **Cursor** authored the skills imported from cursor-team-kit. (c) 2026 Cursor, MIT, see [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit).

## What changed in the fork

- Plugin renamed `pstack` to `lstack`, so skills load as `lstack:<name>` and agents as `lstack:poteto-agent` and `lstack:comment-sicko`. pstack and lstack can be installed side by side.
- `setup-pstack` renamed `setup-lstack`. It writes `~/.claude/lstack-models.md`, not `~/.claude/pstack-models.md`.
- Removed skills: `automate-me`, `what-did-i-get-done`, `thermo-nuclear-code-quality-review`.
- `recall` is restored from pstack-claude v0.9.30 and reads the engineer's synced sessions and Feed posts through `lyralink recall`, and the decision log, alongside chat history. The `automate-me` route is gone with that skill.
- `why` searches the decision log before any other source and cites decision cards. `how` shows the recorded decisions for the area it explains. `reflect` routes each learning to a Feed draft, a decision card through `lyralink reflect`, or a local skill edit.
- Removed the Codex packaging (`.codex-plugin/`). `poteto-mode/references/codex-tools.md` stays because skills link to it.
- The `lyra-mode` output style prefers `lstack:*` when pstack is also installed.
- Added `lyra-mode`, LyraLink's fork of `poteto-mode` and the default entry skill, with its `lyra-agent` subagent. It adds the decision log and Feed rules and shares `poteto-mode`'s playbooks, references, and scripts by relative path.
- Added `lyra-standards`, LyraLink's engineering standards, which lyra-mode loads for every change. Its rules condense `typescript-best-practices`, the principle skills, the code quality lens in `interrogate`, and the Opening a PR playbook. Each engagement can replace a rule by id in `~/.skillshare/engagements/<client>/standards.md`.
- The session-start hook is `hooks/session-start.sh`. It prints `lyralink context` for the project (engagement standards, decisions, and Feed) and replaces `hooks/session-start-context.md`. The lyra-mode entry is `output-styles/lyra-mode.md`, a plugin output style forced on for every session.
- `agents/lyralink-reporter.md` is LyraLink-original. lyra-mode, reflect, and the lyra-mode output style send every write back to LyraLink (Feed posts, reactions, questions, answers, decision flags, `lyralink reflect`) to it as a background subagent, so the engineer never waits on the LyraLink API.
- Added `.claude-plugin/marketplace.json` at the LyraLink repository root.

Everything else is pstack-claude v0.9.30 unchanged. Upstream's notice follows verbatim; its paths say `plugins/pstack/` where this tree says `plugins/lstack/`, and its `CHANGES.md` is [upstream's](https://github.com/michael-denyer/pstack-claude/blob/v0.9.30/CHANGES.md).

---

# Upstream NOTICE (pstack-claude v0.9.30)

This plugin is a port of upstream MIT-licensed work. All upstream copyright notices and license terms are preserved.

## Upstream sources

| Component | Upstream | Copyright | License | License file |
| --- | --- | --- | --- | --- |
| `plugins/pstack/skills/poteto-mode/`, `plugins/pstack/skills/architect/`, `plugins/pstack/skills/arena/`, `plugins/pstack/skills/automate-me/`, `plugins/pstack/skills/figure-it-out/`, `plugins/pstack/skills/how/`, `plugins/pstack/skills/interrogate/`, `plugins/pstack/skills/reflect/`, `plugins/pstack/skills/show-me-your-work/`, `plugins/pstack/skills/tdd/`, `plugins/pstack/skills/typescript-best-practices/`, `plugins/pstack/skills/unslop/`, `plugins/pstack/skills/why/`, `plugins/pstack/skills/principle-*/`, `plugins/pstack/agents/poteto-agent.md` | [cursor/plugins/pstack @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |
| `plugins/pstack/skills/deslop/` | [cursor/plugins/cursor-team-kit/skills/deslop @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/deslop) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/thermo-nuclear-code-quality-review/` | [cursor/plugins/cursor-team-kit/skills/thermo-nuclear-code-quality-review @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/thermo-nuclear-code-quality-review) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/make-pr-easy-to-review/` | [cursor/plugins/cursor-team-kit/skills/make-pr-easy-to-review @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/make-pr-easy-to-review) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/fix-ci/` | [cursor/plugins/cursor-team-kit/skills/fix-ci @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/fix-ci) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/fix-merge-conflicts/` | [cursor/plugins/cursor-team-kit/skills/fix-merge-conflicts @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/fix-merge-conflicts) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/get-pr-comments/` | [cursor/plugins/cursor-team-kit/skills/get-pr-comments @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/get-pr-comments) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/what-did-i-get-done/` | [cursor/plugins/cursor-team-kit/skills/what-did-i-get-done @ e46364b](https://github.com/cursor/plugins/tree/e46364b8be46000b7df0f260550cd712afbb8d36/cursor-team-kit/skills/what-did-i-get-done) | (c) 2026 Cursor | MIT | [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit) |
| `plugins/pstack/skills/teach/`, `plugins/pstack/skills/principle-model-the-domain/`, `plugins/pstack/skills/create-verification-skill/`, `plugins/pstack/skills/maintain-verification-skill/` (v0.11.3 additions) | [cursor/plugins/pstack @ 3fe2823](https://github.com/cursor/plugins/tree/3fe2823ce17c1656c222d4b7c59d3f82fbf20143/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |
| `plugins/pstack/skills/{swarm,no-comments,technical-writing,bro}/`, `plugins/pstack/agents/comment-sicko.md`, `plugins/pstack/skills/poteto-mode/playbooks/{babysit,shipping,orchestrate,autopilot-full,autopilot-stack,worktree-cleanup}.md`, `plugins/pstack/skills/poteto-mode/references/bugbot-triage.md`, `plugins/pstack/skills/poteto-mode/scripts/`, `plugins/pstack/skills/architect/references/design-red-flags.md`, `plugins/pstack/skills/create-verification-skill/references/feature-map-example/` (v0.14.2 additions) | [cursor/plugins/pstack @ 4612556](https://github.com/cursor/plugins/tree/4612556/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |
| `plugins/pstack/skills/poteto-mode/playbooks/multi-phase-plan.md`, `plugins/pstack/skills/poteto-mode/scripts/check-plan.mjs` (v0.14.8 additions) | [cursor/plugins/pstack @ 7314f72](https://github.com/cursor/plugins/tree/7314f72/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |
| `plugins/pstack/skills/principle-attack-the-premise/`, `plugins/pstack/skills/principle-test-behavior-not-implementation/` (post-v0.14.8 additions) | [cursor/plugins/pstack @ e8d856f](https://github.com/cursor/plugins/tree/e8d856f/pstack) | (c) 2026 Lauren Tan | MIT | [LICENSE](LICENSE) |

## What changed in the port

The port is editorial, not mechanical. See [CHANGES.md](CHANGES.md) for the full per-skill audit of substitutions applied.

Summary of structural changes:

- Plugin content lives at `plugins/pstack/` (with its own `.claude-plugin/plugin.json`). The repo root holds `.claude-plugin/marketplace.json` and the LICENSE / NOTICE / README / CHANGES docs.
- `.claude-plugin/marketplace.json` added at repo root so the repo is installable via `/plugin marketplace add`. The marketplace's single plugin entry sources from `./plugins/pstack`.
- `plugins/pstack/.codex-plugin/prompts/<name>.md` stubs added so each public skill is reachable as a slash command on Codex. Claude Code needs no stubs: the skill itself serves `/pstack:<name>`.
- Seven skills imported from `cursor-team-kit`: `deslop`, `thermo-nuclear-code-quality-review`, `make-pr-easy-to-review`, `fix-ci`, `fix-merge-conflicts`, `get-pr-comments`, `what-did-i-get-done`. All copied verbatim — no rewiring needed.
- `plugins/pstack/skills/babysit/` is independently authored as the Claude Code analog of Cursor's `/babysit` built-in. It has no upstream pstack equivalent; its workflow is informed by Cursor's public `/babysit` behavior. No code or prose was copied from any source.
- `plugins/pstack/skills/poteto-mode/scripts/` is vendored from upstream (`watch-pr`, `orch`, `bootstrap.ts`, `worktree-audit.sh`, `package.json`, `bun.lock`). Port edits, each on the forked list `bun tools/sync.mjs --dry-run` prints: `worktree-audit.sh` reads `~/.claude/projects/` instead of Cursor's transcript directory, warns when `jq` or `rg` is missing, reports prunable worktrees, and runs on GNU as well as BSD coreutils; `bootstrap.ts` fails clearly under node and installs production dependencies only; `orch/store.ts` and `orch/orch.test.ts` carry the silent-failure fixes from #35; `package.json` typechecks the whole tree; `tsconfig.json` is port-only. Everything else is upstream's code under the upstream MIT license.
- `plugins/pstack/agents/comment-sicko.md` is upstream's `Comment Sicko` agent, renamed to `comment-sicko` so the name works as a Claude Code `subagent_type`. The body is verbatim.
- A Codex build shares the same `skills/` tree. It adds `plugins/pstack/.codex-plugin/plugin.json`, a root `.agents/plugins/marketplace.json`, and `plugins/pstack/skills/poteto-mode/references/codex-tools.md` (the Claude-to-Codex tool, model, built-in, and per-skill map). Affected skill entry points link to this map so direct invocation works without the optional Codex prompt stubs. See [CHANGES.md](CHANGES.md#codex-port).

## Modifications

Per the MIT license, modifications are permitted. Skill bodies have been edited to substitute Cursor-specific primitives with their Claude Code equivalents (the full substitution table is in [CHANGES.md](CHANGES.md)). All upstream copyright notices in source files (where present) are preserved.

Port-authored files covered by this notice include:

- `plugins/pstack/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json` (repo root)
- `plugins/pstack/.codex-plugin/plugin.json`
- `.agents/plugins/marketplace.json` (repo root)
- `plugins/pstack/skills/poteto-mode/references/codex-tools.md`
- `plugins/pstack/.codex-plugin/prompts/*.md`
- `plugins/pstack/skills/babysit/SKILL.md` (independently authored; workflow informed by Cursor's public `/babysit` behavior)
- `plugins/pstack/hooks/hooks.json` and `plugins/pstack/hooks/session-start-context.md` (the auto-fire hook and its mandate)
- `NOTICE.md` (this file)
- `NOTICE-skills.md`
- `README.md`
- `CHANGES.md`

`LICENSE-cursor-team-kit` is copied verbatim from upstream cursor-team-kit rather than authored for this port.
