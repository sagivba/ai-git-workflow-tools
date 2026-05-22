# AI Git Workflow Tools - AI Agent Contract

When working in a repository that adopted this toolset, AI agents MUST use AGW commands for Git/GitHub workflow operations whenever an AGW command exists.

Direct `git` or `gh` commands are fallback-only.

Before suggesting or running any direct `git` or `gh` command, the agent MUST ask:

1. Is there an AGW command for this operation?
2. If yes, use AGW.
3. If no, direct Git/GitHub CLI may be used, and the reason must be stated.

AGW is the workflow interface.
Git and GitHub CLI are implementation details.

