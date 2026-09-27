---
name: recall
description: "Reconstruct your recent working context from your own chat history, your synced LyraLink sessions, your Feed posts, live state, and the shared record (decision log, team Feed, user reports, prior fixes, incidents), then hand back a tight current-state brief. Use for 'recall my work on X', 'catch me up', 'what have I been working on', 'where did I leave off', before starting or resuming work, and before telling the user that something was never recorded."
---

# Recall

**Before you start or resume work, you rebuild the user's recent working context and hand back a tight capsule of where things stand now and what to do next.**

Keep it tight and on-topic. Read only what the in-scope threads need, then stop.

Your context lives in three records. Your own chat history holds what you did and decided in this workspace. Your LyraLink record holds what survives across machines and agents: every session you synced (when, which agent, client or org, task type, skills used, loops hit, PR outcome) and every Feed post or draft you wrote. The shared record holds everything that happened around the same code under other names: the decisions the team recorded, the gotchas teammates posted, the symptoms users keep reporting, the fixes that shipped and got reverted, the errors still firing in prod. That last record is what the **why** skill searches. A feature with a long bug tail keeps most of its story there, so don't reconstruct it from your transcripts alone.

Transcripts live at `~/.claude/projects/<encoded-cwd>/<uuid>.jsonl`, where `<encoded-cwd>` is the workspace path with the leading slash dropped and each "/" turned into "-" (so `/Users/you/proj` becomes `-Users-you-proj`). Every line is one chat message.

1. Classify, then route. One specific prior chat to resume is the `session-pickup` playbook (`../poteto-mode/playbooks/session-pickup.md`), not this. A human-readable summary of your work is a different task. Recall loads working context across recent chats before you act. If the user already gave you a full state capsule (paths, branch, the change), use it and skip the mining.
2. Lock the scope before searching. Pin the window ("recent" is a real range, default the last 7 days), the topic if named, and the workspace (default the active one; never read another project's transcripts without being asked). State the scope back. Never quietly turn "all" into "recent N".
3. Read your LyraLink record. Run `lyralink recall --since <N>d --json`, adding `--q "<topic>"` when the topic is named. It returns only your own sessions and posts:
   - `sessions`: your synced sessions in the window, newest first, from any machine and any agent. They hold no prompt text, so use them for shape and outcome: which days you worked, on which client, what kind of task, where you looped, and whether the PR merged or was reverted. A session with no local transcript was run elsewhere; say so rather than treating it as missing.
   - `feed.mine`: your Feed posts and drafts in the window. A draft still waiting in `lyralink feed review` is an open thread.
   - `feed.topic`: other engineers' Feed posts on the topic. Fold them in with the shared record in step 5.
   - `apiErrors`: a source that was down. The local copy still answers, so continue and name the gap in the brief.
   If `lyralink` is missing or not initialised, say so in one line and continue without it.
4. Fan out across your chat history. Spawn parallel subagents on a fast, cheap model, each taking a slice of the corpus. Tell every subagent to order candidates by real modification time (`ls -t`) and never by UUID name, grep the topic first and then read only the matching chats and only their relevant regions, and skip the current chat plus obvious noise (subagent, eval, and test chats). Each returns the same schema, one block per chat: topic, the user's goal, decisions, open threads, struggles and corrections, and artifacts (PRs, tickets, branches), each citing the chat UUID. For one or two chats, skip the fan-out and search directly. The raw transcripts stay in the subagents. The main thread gets only their findings. Match chats to synced sessions by session id where you can.
5. Sweep the shared record whenever the topic names a feature, file, subsystem, area, or bug. This is the default, not a judgment call, and "my work on X" does not exempt it. Start with the decision log: `lyralink decisions search "<topic>" --json`, then `lyralink decisions show <id> --json` for each hit, so the brief cites what was settled and what was rejected. Then hand the rest to the **why** skill's source investigators, but steer their question from "why was this built this way" to "what's the current state, what's been tried and didn't hold, and what are users still reporting". Reuse its per-source playbooks, run the investigators in parallel with the chat-history mining, and inherit its posture: one investigator per source, null results are findings, skip an unavailable MCP and say so. Fold what comes back into the brief. Also sweep every location the project's standing rules name for queued or recorded items (a memory directory, a `.planning/` tree, a project CLAUDE.md pointer) before you report anything as never recorded. A search that skips a place the project's rules name, including the decision log and your Feed drafts, is not exhausted. Skip this step only for pure activity recall with no named target ("what did I do this week"), where your own history, your LyraLink record, and live state are the entire answer.
6. Verify against live state. Take the PRs, branches, and tickets that the mining and the sweep surfaced and check them with `git` and `gh`. When the answer hinges on what an agent actually did (the tools it ran, files it read, errors it hit), read the full transcript, not just a trimmed local copy.
7. Write the brief to the contract below. Group by thread. Stay on the named topic.

## Output contract

Lead with the capsule, then the thread status, then the problems, then the next move. Deeper detail goes below or gets cut.

- **Capsule.** At most 5 bullets. What this work is and where it stands overall.
- **Threads.** One line each, prefixed with exactly one status tag: `[merged #N]`, `[open PR #N]`, `[in flight <branch>]`, `[verified, uncommitted]`, `[reverted #N]`, `[draft <post id>]`, or `[planned, not started]`. A thread with no tag is not done yet, so tag it.
- **Problems.** At most 5, the recurring ones. Include the symptoms users keep reporting, loops your synced sessions show, Feed posts that describe the same failure, and any fix that shipped and was reverted, so the next attempt starts where the last one failed.
- **Decisions.** The decision cards that constrain the next move, as "decision `<id>` (<title>)". Omit when none apply.
- **Next move.** The single most useful next action, concrete.

An adjacent feature or ticket stays out unless it blocks this one. When the capsule and thread lines outgrow a screen, cut detail before you cut threads. Write the brief through the **unslop** skill. Cite chat findings by UUID, synced sessions by session id, Feed posts by post id, decision cards by id, and other shared-record findings by their source (PR #, ticket ID, chat permalink, error-tracker issue). Sanitize private context before any public output; engagement posts and sessions name a client and stay out of anything shared outside that engagement.

**Reply:** the brief, to the contract above.
