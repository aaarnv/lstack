---
name: setup-lstack
description: Set up lstack for this engineer. Checks the LyraLink sign-in, configures which models lstack uses per role (a per-role override file included from CLAUDE.md), then shows your setup vs the org from lyralink setup diff and offers to install the missing skills the org registry has. Use for /setup-lstack, "configure lstack models", "what am I missing vs the org", or changing lstack's model choices.
---

# Setup lstack

On Codex, read the [platform mapping](../poteto-mode/references/codex-tools.md), including its per-skill notes, before following this skill.

This is pstack's `setup-pstack` forked for LyraLink. It does three things in order: checks that `lyralink` is signed in, writes `~/.claude/lstack-models.md` (the per-role model override sheet), and walks the engineer through their setup vs the org with an offer to install the skills they are missing.

Each lstack skill names a default model inline; the override sheet adapts those defaults to the models the user has. Claude Code has no auto-applied "rules" mechanism like Cursor's `.mdc`, so inclusion is explicit: `~/.claude/CLAUDE.md` (or a project `CLAUDE.md`) carries the line

```text
@~/.claude/lstack-models.md
```

and the file loads as context for every session.

Every `lyralink` command below prints JSON with `--json`. Never ask for, print, or pass an API token; `lyralink` reads the saved one.

## Steps

### 1. Check the LyraLink sign-in

Run `lyralink setup check --json`.

- `{ "ok": true, "engineerId": ..., "org": { "slug": ..., "name": ... }, "apiUrl": ... }`: tell the user they are signed in to that org as that engineer, and continue.
- `{ "ok": false, "error": ... }`: show the error. It names the fix, usually "run `lyralink login`" (browser sign-in), or "create an API token in Settings > CLI and run `lyralink init --token <token>`". Offer to wait while they do it, then re-run the check. If they would rather skip, continue with the model steps and skip steps 8 and 9.
- `lyralink` is not on `PATH`: say LyraLink is not installed, continue with the model steps, and skip steps 8 and 9.

### 2. Detect available models

Enumerate the model slugs you can pass to an `Agent` subagent in this session — that is the dependable source. The currently available Claude models and the default panel are listed in [Models](#models) below; the panel is chosen for cross-family, cross-tier diversity, and the single-role default stays out of the panels because it already covers the single-model roles. Ask the user to confirm or paste any additional slugs they want available. Never write a real slug you have not confirmed is available. The aliases `inherit-parent` and `auto` are always valid even though they are not detected slugs; both mean the role runs on the parent session's model, which the `Agent` call expresses by omitting `model`.

### 3. Load current state

The default role-to-model mapping is the sheet shown in step 6 below. If `~/.claude/lstack-models.md` already exists, read it and treat its values as the current choices. Otherwise start from those defaults. A line whose role is not in step 6 is from a retired role. Drop it.

### 4. Map and confirm

Show every role with its current model, marking any real slug not in the detected set as needing a choice. Also list each line step 3 dropped. Ask whether to accept as-is or change specific roles, offering the detected models plus `inherit-parent` and `auto` as the options. Prefer `AskUserQuestion` over free text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, alias entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena selects one value from it whose model family differs from the parent's when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 5. Validate

Every real slug written must be in the detected set; `inherit-parent` and `auto` always pass. If a chosen real slug is not available, stop and ask again.

### 6. Write the override sheet

Write `~/.claude/lstack-models.md` with the shape below. Overwrite the whole file so re-runs stay idempotent.

```markdown
# lstack model configuration

Per-role model overrides for lstack skills. Each lstack SKILL.md names its defaults in a Models section; the values here override those defaults. Delete a line to fall back to the skill default. A value of `inherit-parent` or `auto` runs that role on the parent session's model (the `Agent` call omits `model`); an alias entry in a panel list still counts toward that panel's fan-out.

feature, refactoring: claude-opus-5
bug-fix: claude-fable-5-1
perf-issue: claude-fable-5-1
hillclimb: claude-fable-5-1
judgment and prose: claude-opus-5
strongest judgment: claude-fable-5-1
how explorer: claude-opus-5
how explainer: claude-opus-5
why investigators: claude-opus-5
why synthesizer: claude-opus-5
reflect tooling: claude-opus-5
reflect judgment, divergent, synthesizer: claude-opus-5
arena runners: claude-opus-5, claude-fable-5-1, claude-sonnet-5
arena cross-judge pool: claude-opus-5, claude-fable-5-1, claude-sonnet-5
swarm workers: claude-opus-5
architect runners: claude-opus-5, claude-fable-5-1, claude-sonnet-5
interrogate reviewers: claude-opus-5, claude-fable-5-1, claude-sonnet-5
```

### 7. Wire it in

If `~/.claude/CLAUDE.md` does not already include `~/.claude/lstack-models.md`, append the `@~/.claude/lstack-models.md` line so it loads on every session. If the user prefers project scope, add the include to the project's `CLAUDE.md` instead.

### 8. Your setup vs the org

Skip this step when step 1 did not end signed in.

Run `lyralink setup diff --json`. It returns `{ ok, engineerId, hasSnapshot, suggestions, installed }`. Each suggestion has an `item` (`{ kind: "skill", name }`, `{ kind: "mcp", name }`, or `{ kind: "hook", event, command }`), its `evidence`, and `inRegistry`.

- `hasSnapshot` is false: LyraLink has not seen this engineer's setup yet. Say to run `lyralink sync`, then re-run `/setup-lstack`. Skip step 9.
- `suggestions` is empty: say there is nothing to add. An item shows up when 3 or more engineers with a high merge rate on the user's task types have it and they do not. Skip step 9.
- Otherwise list every suggestion, grouped by kind, with one line per evidence entry in the form "`engineerCount` of `groupSize` engineers with a high `taskType` merge rate have it." Say once, verbatim: "This is a correlation. It does not show that an item causes merges." The API returns counts only; never guess or name which engineers have an item.

### 9. Offer to install the missing registry skills

The installable set is every suggestion with `item.kind` `skill` and `inRegistry` true.

- Empty: say no suggested skill is in the org registry yet, and move on.
- Otherwise ask with `AskUserQuestion`, `multiSelect: true`, one option per installable skill (label: the skill name; description: its strongest evidence line), plus `Install none`. Install only what the user picks: `lyralink setup diff --install <name>[,<name>...] --json`. Report each entry of `installed`: `ok: true` landed in `~/.claude/skills/<name>`, `ok: false` carries the reason. A name outside the installable set is refused and installs nothing, so pass the picked names exactly.

For what the registry cannot install, describe and stop:

- A skill with `inRegistry` false is not published yet. Suggest asking someone who uses it to publish it with `lyralink publish <path> --scope org`.
- An MCP server goes under `mcpServers` in `~/.claude.json`; a hook runs its `command` on its `event` from `~/.claude/settings.json`. Never edit either file from this skill. Show the item and let the user add it.

Installed skills load in the next Claude Code session, and the next `lyralink sync` uploads the new setup so the diff drops them.

### 10. Confirm

Tell the user, in a few sentences: who they are signed in as (or that sign-in was skipped), where the override sheet was written and how it loads (the `@` include in `CLAUDE.md`), and which skills were installed. Re-running this skill updates the sheet and re-reads the diff.

### 11. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, a `.claude/skills/verify/` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `lstack:create-verification-skill`. On no, move on without pushing.

## Models

Stamped from `plugins/lstack/models.json`.

- Available Claude models: Opus 5 (`claude-opus-5`), Opus 4.8 (`claude-opus-4-8`), Opus 4.6 (`claude-opus-4-6`), Fable 5.1 (`claude-fable-5-1`), Sonnet 5 (`claude-sonnet-5`), Sonnet 4.6 (`claude-sonnet-4-6`), Haiku 4.5 (`claude-haiku-4-5`)
- Default panel: `claude-opus-5`, `claude-fable-5-1`, `claude-sonnet-5`
- Single-role default: `claude-opus-5`
