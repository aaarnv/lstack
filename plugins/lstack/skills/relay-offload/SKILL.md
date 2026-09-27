---
name: relay-offload
description: "Use when local verification or parallel coding work competes for machine capacity. Inspect capacity, use hybrid offloading for approved verification commands, and explicitly dispatch other suitable work."
---

# Hybrid relay offloading

Run `lyralink relay capacity --json` before launching expensive parallel work. The view includes local pressure, active managed commands and remote eligibility. `--agent` limits eligibility to runners that can execute agent jobs. If unavailable, keep working with the information you have; do not invent remote capacity.

Approved exact verification commands are managed automatically by the PreToolUse hook after `lyralink relay offload enable` has enabled the repository's `.lyralink/offload.json`. Healthy local capacity takes a local slot. Busy pressure or full slots sends the command to an eligible idle remote runner. The command and routing reason remain visible. An unapproved command stays unchanged. Never create or broaden an automatic list just to bypass a capacity error; configure only commands within the user's agreed verification scope.

For everything outside that list, choose local execution, an explicit remote job or waiting. Consider snapshot size, dependency setup, local-only services, credentials and whether repeating the command could cause external effects. Within the user's authorized task, do not request approval for every ordinary job.

```sh
lyralink run @any --timeout 10m 'pnpm typecheck'
lyralink run @engineer-id --agent 'Implement the bounded change and run its focused checks'
lyralink apply Txxxxxx
```

Explicit jobs only transmit named secrets and allowed domains. Do not silently add credentials or network access. Relay jobs cannot run Docker, databases or persistent dev services as transparent replacements. Offload bounded work that can complete from a snapshot. Agent jobs use Claude on the runner; use them only when the user has not required another model/client. They return a patch, not a remote checkout you can directly inspect. Ask the worker to include verification output, inspect the result and apply to a clean original base on a new branch.

When no capacity is available, automatic execution returns exit 75 without dispatching. Decide whether to wait, defer or explicitly run locally. After remote dispatch, failure does not trigger a local retry: inspect/cancel the thread before starting another copy. Do not duplicate queued/running work. Jobs and relay forks must never recursively offload.

For a swarm or arena, assign each remote job a bounded independent slice and track its thread/result. Aggregate all required results before synthesizing. Keep local workers for model-specific tasks and work requiring local services. For missing teammate knowledge, use `lyralink ask @engineer "question" --wait` instead of spawning speculative work.
