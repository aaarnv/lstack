---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to where it helps most. Team knowledge becomes a Feed draft or a decision card; lessons about how the agent works become local skill edits. Use when the user says reflect.
---

# Reflect

On Codex, read the [platform mapping](../poteto-mode/references/codex-tools.md), including its per-skill notes, before following this skill.

Mine the current conversation for durable learnings, then route each one to where it will be found again:

- **Feed draft.** A gotcha, fix, pattern, or tool tip about this codebase or stack that any engineer on it would hit. Lands in `lyralink feed review`; nothing publishes until the engineer approves it.
- **Decision card.** A settled choice between named alternatives, with why the others lost. You write the card; it lands in the decision log once Jev approves it.
- **Local skill edit.** A lesson about how the agent should work. Edits a skill on this machine.

## When to invoke

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The parent finds its own transcript file before fanning out. The system prompt names Claude Code's per-project transcripts directory at `~/.claude/projects/<encoded-cwd>/`; use that path. Do not glob across `~/.claude/projects/`. That crosses workspace boundaries and reads private chats from unrelated projects.

Run the finder at `skills/reflect/scripts/find-transcript.mjs` under the installed plugin with the projects directory and a fragment of the conversation's opening user prompt:

```bash
node <plugin>/skills/reflect/scripts/find-transcript.mjs ~/.claude/projects/<encoded-cwd> "<opening prompt fragment>"
```

It covers the three layouts (flat `<id>.jsonl`, nested `<id>/<id>.jsonl`, subagent `<parent>/subagents/<child>.jsonl`), newest first, and prints the first path whose opening `user` record carries the fragment. Do not reimplement the scan by hand: the first line of a transcript is session metadata, not a message, and files run to several megabytes, so the finder streams each candidate and stops at its first `user` record. If it exits 1, write a tight digest of the session and pass that instead.

### 2. Route the mechanical learnings

Run the detectors over the transcript before the reviewers read it:

```bash
lyralink reflect --transcript <transcript path> --json
```

It routes what a detector can see without judgment. A tool that failed the same way three times becomes a `fix` Feed draft, and the engineer correcting the agent becomes a `gotcha` Feed draft. Each plan approval, answered question, explicit choice, or revert that has no card yet is listed by its key for you to draft in step 6, since you read the session and no other model does. It prints one line per step, such as `feed: fix drafted post-...` or `decisions: 2 waiting for the agent: plan-approval@..., explicit-choice@... (lyralink decisions draft)`. It shares capture's record of what it handled, so rerunning it or ending the session later drafts nothing twice. A transcript outside the engineer's scannable directories, or while sync is paused, routes nothing; report that line and continue.

This step runs without asking, and never in the main thread: hand the command to a `lstack:lyralink-reporter` subagent with `run_in_background: true`, in the same message as step 3's reviewers, so the detectors and Jev review run while the reviewers read. It does exactly what SessionEnd capture would do for this session, and its Feed drafts still wait for review. Collect its `lines` from the reporter's reply before step 4 and pass them to the synthesizer. If `lyralink` is missing or no transcript path was found, skip this step and say so in the summary.

### 3. Spawn three reviewers in parallel

One message, three `Agent` calls, `subagent_type: "general-purpose"`, explicit `model:` on each. Reviewers need MCP access for context lookups (tickets, chat threads, observability traces referenced in the transcript); pick a subagent_type that retains MCP access. The prompt forbids file writes; the parent applies edits.

| Lens | `model` | Prompt template |
|---|---|---|
| Judgment | your configured reflect-judgment model (default in [Models](#models)) | `references/judgment-reviewer.md` |
| Tooling | your configured reflect-tooling model (default in [Models](#models)) | `references/tooling-reviewer.md` |
| Divergent | your configured reflect-judgment model (default in [Models](#models)) | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the `Agent` response body.

### 4. Synthesize

One `Agent` call, `subagent_type: "general-purpose"`, using your configured reflect-judgment model (default in [Models](#models)). Pick a subagent_type that retains MCP access — the synthesizer's quality check includes spot-verifying citations, which can require MCP access. Use `references/synthesizer.md` verbatim, with each reviewer's full output and the `lyralink reflect` lines from step 2 inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 5. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. See the **encode-lessons-in-structure** principle skill.

### 6. Apply

Before applying any Accepted item, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent that loads the skill, and Feed drafts and decision cards reach the whole team; do not auto-apply.

Backlog items file to whatever devex / backlog tracker your team uses automatically. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly. Batch every `lyralink feed post` into one `lstack:lyralink-reporter` subagent with `run_in_background: true`, apply the local skill edits yourself while it runs, and report the draft ids from its reply in the summary.

- `feed draft: <kind>`: create the draft with the proposal's fields. Use `--scope engagement --client <slug>` when the session was client work and `--scope org` otherwise, the repo's stack as `--tags`, and the transcript's session id as `--session` and `--source`. The draft waits in `lyralink feed review` for the engineer to approve, edit, or drop; say so in the summary.

  ```bash
  lyralink feed post --scope org --kind <kind> --title "<title>" --body "<body>" \
    --trigger "<trigger>" --tags <a,b> --session <session id> --source <session id> --json
  ```

  `feed post` rejects a draft that trips the secret scan and caps drafts at three per session. Rewrite a rejected draft without the secret rather than retrying it as is.
- `decision card`: cards reach the decision log only through Jev review, and `lyralink decisions draft` is the path that runs it. Match the card to the moment key step 2 listed for that choice, write its JSON, and batch the commands into the same background `lstack:lyralink-reporter` as the Feed posts:

  ```bash
  lyralink decisions draft --transcript <transcript path> --moment <key> --json <<'CARD'
  {"title": "<=100 chars", "decision": "...", "context": "...", "options": [{"label": "...", "outcome": "kept", "reason": "..."}], "reasoning": "...", "consequences": "...", "area": null, "tags": ["..."]}
  CARD
  ```

  Leave out client names, file paths, branch names, URLs, tickets, identifiers, secrets, and code; the command strips and scans them anyway, and a secret rejects the card. Jev drops what isn't a real decision and keeps a card engagement-only unless it holds no client details. Org cards Jev approves are published to the org log; only the redacted card leaves the machine. A listed moment that is not a decision gets `--skip` instead of a card. A choice with no listed moment goes in the summary as a proposed card; when it replaces an accepted card, cite that card and suggest `lyralink decisions flag <id> --reason "<why>"`. Never flag a card by hand.
- Skill edits stay local. Edit the skill file on this machine: the lstack checkout, `~/.claude/skills/`, or the engagement's skill. Sharing it with the team is a separate `lyralink publish`, which is the engineer's call.
- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to the **plugin-dev:skill-development** skill and run its draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `plugin-dev:skill-development` and run its description-optimization loop.
- `new skill via plugin-dev:skill-development: <kebab-name>`: hand creation to `plugin-dev:skill-development`. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 7. Summarize for the user

Short list, no preamble:

- Feed drafts: `<post id>` `<kind>` "<title>", waiting in `lyralink feed review`. One line each, from step 2 and step 6.
- Decision cards: `<id>` accepted, published, or dropped, with Jev's reason when dropped. Proposed cards with no listed moment, one line each.
- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.

## Models

Role defaults, stamped from `plugins/lstack/models.json`. A matching role line in `~/.claude/lstack-models.md` overrides each at runtime; see `/setup-lstack`.

- reflect tooling: `claude-opus-5`
- reflect judgment, divergent, synthesizer: `claude-opus-5`
