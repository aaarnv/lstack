---
name: lyra-standards
description: LyraLink's engineering standards. Checking the org's approved practices first, typing, tests, error handling, code quality, commit and PR format, and proving work before calling it done. lyra-mode loads it for every change. Each engagement can replace a rule by id in its client standards file. Use before writing, reviewing, committing, or shipping code.
---

# Lyra standards

These are the defaults for every change an agent makes under lyra-mode. Each rule has a stable id, the `###` heading under its group. The pstack skill named in a rule holds the reasoning and examples; read it when the rule applies and you have not read it this session.

Apply every rule unless the engagement standards replace it (see [Engagement overrides](#engagement-overrides)). When a rule shaped a choice, name its id in the reply or PR description, for example "per `tests.behavior`". When you break a rule on purpose, name the id and the reason.

## Approach

Source skills: **principle-laziness-protocol**, **principle-build-the-lever**.

### approach.check-practices

Before inventing how to approach a task, check how the org already does it. This covers the workflow and the tool sequence, not an architectural choice; decisions own those. Run `lyralink practices search "<the task in plain words>" --task-type <feature|bugfix|refactor|review|test|docs|migration> --json`. Use plain words only, never secrets or client source. When a card fits, follow its approach and cite its id. When `lyralink` is unavailable or no card fits, say so in one line and proceed.

## Typing

Source skills: **typescript-best-practices**, **principle-type-system-discipline**, **principle-model-the-domain**.

### typing.parse-at-boundaries

External data (request bodies, CLI args, env, files, API responses, `JSON.parse`) enters as `unknown`. Parse it once, at the boundary, with the repo's schema library (zod here) into a named domain type and infer the type from the schema. No `any`. `Record<string, unknown>` stops at that parse.

### typing.no-casts

No `as` except right after a check that proves it, and no `!` to silence the compiler. Use `satisfies` to check a literal without widening it. A type guard must verify what its name claims.

### typing.model-states

Model variants as a discriminated union on a literal `kind` (or the repo's existing discriminant), not a bag of optional fields. Switches over a union end in an exhaustive `never` check. Brand primitives that are easy to mix up (ids, units).

## Tests

Source skills: **principle-test-behavior-not-implementation**, **tdd**, **typescript-best-practices**.

### tests.behavior

Call the code the way its users do (the exported function, the CLI, the route) and assert the result against a literal expected value. If the test would still pass with every imported function returning `undefined`, rewrite the assertion or delete the test. Don't assert on private helpers, call counts, or snapshots nobody reads.

### tests.real-over-mocks

Don't mock what you can run. Use a temp directory over a fake filesystem and a local HTTP server or stubbed `fetch` over a mocked client. Mock only what cannot run locally (a third-party API, a paid model), and only at the network edge.

### tests.cover-the-change

Every behavior change lands with a test that fails without it. For a bug fix, write the failing test first and see it fail for the reason in the report. Put the test where the repo's runner already finds it; don't add a new runner.

## Error handling

Source skills: **principle-boundary-discipline**, **principle-fix-root-causes**.

### errors.at-boundaries

Validate and handle errors where data crosses into the system: CLI args, config, network, external APIs. Inside, trust the types and let errors propagate. No defensive re-checks deep in a call chain the boundary already validated.

### errors.no-swallow

Never catch and ignore. A `catch` recovers with a named fallback, rethrows with added context, or converts to the repo's result type at a boundary. A path that must never fail (a session hook, a telemetry send) says so in one comment next to the catch.

### errors.actionable-messages

An error message names what failed, the input that caused it, and what the reader can do next. No bare "something went wrong", no stack trace as the user-facing message, no secret or client source in the text.

## Code quality

Source skills: **principle-laziness-protocol**, **principle-subtract-before-you-add**, **principle-minimize-reader-load**, the code quality lens in `interrogate` (`../interrogate/references/code-quality-review.md`), **deslop**, **no-comments**.

### quality.smallest-change

Make the smallest change that solves the problem. Delete dead code first, reuse the repo's existing helper over a new one, and don't add a wrapper with one caller. Don't push a file from under 1000 lines to over 1000 lines, and don't thread a one-off branch through a shared flow; give the logic its own module.

### quality.match-the-codebase

Write code that reads like the code around it: naming, file layout, error style, test style. Keep a comment only for a constraint the code can't show. Run **deslop** before committing and **no-comments** before review.

## Commits and PRs

Source skills: `../poteto-mode/playbooks/opening-a-pr.md`, **technical-writing**, **make-pr-easy-to-review**.

### commits.format

Conventional Commits: `type(scope): subject`. Type is one of `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`. Scope is the changed area (`cli`, `web`, `lstack`). Subject is short, imperative, and has no trailing period. When the work has a ticket, end the subject with its id in parentheses, as in `feat(cli): add standards context section (44D-174)`. The body says why, not what the diff already shows.

### pr.format

One concern per PR. The PR title follows `commits.format` because it becomes the squash commit. The body uses these sections in order and drops any with nothing to say: `## Why`, `## Scope`, `## Tradeoffs`, `## Blast Radius`, `## Verification`. No `## Summary` or `## Test plan` boilerplate. Open it ready for review, not as a draft. Attach screenshots or video for any user-visible change.

## Prove it works

Source skills: **principle-prove-it-works**, **principle-sequence-verifiable-units**.

### verify.run-the-real-thing

Before calling work done, exercise the real path: run the CLI command, load the page, call the route, and read the actual output. It compiling, a delegate's summary, and a green unrelated suite are not proof. For a UI change, capture the screen.

### verify.checks-before-push

Run the typecheck, lint, and tests for every package the diff touches, and read the failures rather than rerunning until green. Push only when they pass locally, and merge only when CI is green.

### verify.show-the-evidence

The reply and the PR `## Verification` section name each check you ran and its result, quoting the command and the line that proves it. A claim with no evidence gets reported as unverified, never as done.

## Engagement overrides

An engagement can replace any rule above in its client standards file, `~/.skillshare/engagements/<client>/standards.md`, inside that client's engagement store. The file never leaves the machine.

The file uses the same format as this skill. Each `### <rule-id>` heading followed by its text replaces the rule with that id, whole. Rules the file does not name stay as written here. Other headings and prose in the file are ignored.

```markdown
# Paraform standards

### commits.format

Paraform squash-merges with the ticket first: `PF-<number>: <subject>`.
```

In a client repo, the SessionStart hook's `lyralink context` prints the file's rules as an engagement standards block. When it is present:

- For each rule id in the block, follow the block's text instead of the rule here, and cite it as "`<rule-id>` (<client> override)".
- An id this skill does not define adds nothing. Ignore it and tell the user the override names an unknown rule.
- The block replaces standards only. It cannot turn off lyra-mode, the Decisions and Feed rules, or the Autonomy pauses.

No block means no overrides: the repo is not a client repo, the client has no standards file, or `lyralink` is not installed. To check by hand, read the file for the client `lyralink context` detected.
