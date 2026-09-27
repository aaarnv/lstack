---
name: how
description: "Use for \"how does X work\", code walkthroughs before changing something, and placement / ownership / layering questions (\"where should this live\", \"which package owns this\", \"is this the right layer\"). Explains subsystem architecture, runtime flow, onboarding mental models, and shows the team's recorded decisions for the area. Use why for motivation."
---

# How

On Codex, read the [platform mapping](../poteto-mode/references/codex-tools.md), including its per-skill notes, before following this skill.

Explore the codebase to answer "how does X work?" questions. Produce architectural explanations at the level of a senior engineer onboarding onto a subsystem, enough to build a working mental model, not so much that it reads like annotated source code.

## Step 1. Pull the Area's Decisions

Name the area being explained in a word or two (auth, search, database, ci, exports). Then read the team's decision log for it:

```bash
# The area as a hard filter, then the subject as free text
lyralink decisions search "<subject>" --area <area> --json
lyralink decisions search "<subject>" --json

# Each card that bears on the area
lyralink decisions show <id> --json
```

Keep the accepted cards that govern how this area is built: its datastore, boundaries, auth model, libraries, or conventions. The explanation shows each one, because a reader about to change the area needs to know which of its shapes were chosen on purpose and what was rejected. Use plain words, never secrets or client source. If nothing matches or `lyralink` is unavailable, note "No recorded decisions for <area>" and continue.

## Step 2. Assess Complexity

If the scope is ambiguous, state your interpretation and explore. The user can redirect.

- **Simple** (a single module, a small utility, a narrow question such as "how does function X work"): no explorers. One explainer explores and explains in a single pass. Go to Step 3b.
- **Complex** (a subsystem spanning multiple files or services, a cross-cutting feature, a full architectural overview): spawn parallel explorers first, then hand off to the explainer. Go to Step 3a.

When in doubt, take the simple path.

## Step 3a. Explore (complex questions only)

Decompose the question into 2 to 4 exploration angles, each a distinct slice of the subsystem. Spawn all explorers in a single message:

- `subagent_type`: `general-purpose`
- `model`: your configured how-explorer model (default in [Models](#models))
- `readonly`: `true`

Each explorer gets the prompt in `references/explorer-prompt.md` with its angle filled in. Then go to Step 4.

## Step 3b. Direct Explain (simple questions)

Spawn one Task subagent that explores and explains in one pass:

- `subagent_type`: `general-purpose`
- `model`: your configured how-explainer model (default in [Models](#models))
- `readonly`: `true`

Build its prompt from `references/explainer-prompt.md` without the explorer-findings section, with the decision cards from Step 1 filled in. Go to Step 5.

## Step 4. Synthesize (complex questions only)

Once all explorers have returned, spawn one Task subagent to synthesize their findings into one explanation:

- `subagent_type`: `general-purpose`
- `model`: your configured how-explainer model (default in [Models](#models))
- `readonly`: `true`

Build its prompt from `references/explainer-prompt.md` with every explorer's findings and the decision cards from Step 1 filled in.

## Step 5. Present

Present the explainer's output to the user. Light edits for clarity or context from the conversation are fine. Do not substantially rewrite it, and keep the Decisions section with each card cited as "decision `<id>` (<title>)".

## Output Format

The explanation uses the sections defined in `references/explainer-prompt.md`, dropping any that do not apply: Overview, Key Concepts, How It Works, Decisions, Where Things Live, Gotchas. Decisions stays even when empty, as the one line saying no decision is recorded for the area.

## Models

Role defaults, stamped from `plugins/lstack/models.json`. A matching role line in `~/.claude/lstack-models.md` overrides each at runtime; see `/setup-lstack`.

- how explorer: `claude-opus-5`
- how explainer: `claude-opus-5`
