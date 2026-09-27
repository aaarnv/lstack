# l-stack

l-stack is [LyraLink](https://www.lyralink.dev)'s plugin of agent workflows for Claude Code and Codex. It is a fork of pstack. It adds lyra-mode, LyraLink's engineering standards, and hooks that call the `lyralink` CLI when it is installed.

## Install l-stack

Add the marketplace, then install the plugin:

```sh
claude plugin marketplace add aaarnv/lstack
claude plugin install lstack@lyralink
```

If you use LyraLink, run `lyralink install lstack` instead. It installs l-stack in each agent you enabled in LyraLink.

## This repository is a published copy

LyraLink publishes this repository from its private source repository. Each publish replaces every file here, so a direct change to this repository does not last.

## Credits

l-stack is a fork of [pstack-claude v0.9.30](https://github.com/michael-denyer/pstack-claude/tree/v0.9.30).

- Lauren Tan (poteto) wrote the original [pstack](https://github.com/cursor/plugins/tree/main/pstack).
- Michael Denyer ported pstack to Claude Code as [pstack-claude](https://github.com/michael-denyer/pstack-claude).
- Cursor wrote the skills that l-stack imports from cursor-team-kit.

All three are MIT licensed. [`plugins/lstack/NOTICE.md`](plugins/lstack/NOTICE.md) lists every credit and every change in the fork. [`LICENSE`](LICENSE) holds the license text.
