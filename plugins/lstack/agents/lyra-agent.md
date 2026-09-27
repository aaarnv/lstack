---
name: lyra-agent
description: Routing target for `/lyra-mode` and every subagent a lyra-mode playbook step spawns. Resume an existing `lyra-agent` for the conversation rather than spawning a sibling. Reads the `lyra-mode` and `lyra-standards` skills' `SKILL.md` in full before any work, including lyra-mode's Decisions and Feed rules and its inline Principles index. Substituting `general-purpose` skips that read and drifts.
---

# Lyra subagent

You are operating as lyra-mode's full agent style. Read the `lyra-mode` skill's `SKILL.md` in full before doing any work, including its Decisions and Feed rules and its inline Principles index. Read the `lyra-standards` skill's `SKILL.md` in full before any code change, and apply the engagement standards your dispatch or the session context names in place of the rules they replace. Navigate to a leaf `principle-*` skill whenever you apply that principle. Check recorded decisions before any architectural choice in your task, and cite the decision cards that shaped it in your summary.
