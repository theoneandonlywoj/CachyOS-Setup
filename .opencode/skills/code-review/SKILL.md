---
name: code-review
description: Review changes since a fixed point along two axes — Standards and Spec — using parallel subagents. Use when the user wants to review a branch, PR, work-in-progress, or asks to review since X.
---

# Code Review

Two-axis review of the diff between `HEAD` and a fixed point the user supplies.

- **Standards** — does the code conform to the repo's documented standards?
- **Spec** — does the code faithfully implement the originating issue / PRD / spec?

Both axes run as parallel subagents so they don't pollute each other, then this skill aggregates their findings.

## Process

### 1. Pin the fixed point

Use the user's fixed point (commit, branch, tag, `main`, `HEAD~5`). If none, ask.

Capture the diff once:

```bash
git diff <fixed-point>...HEAD
git log <fixed-point>..HEAD --oneline
```

Confirm the ref resolves and the diff is non-empty.

### 2. Identify the spec source

Look in this order:

1. Issue references in commit messages
2. A path passed as argument
3. `docs/`, `specs/`, `.scratch/` matching the branch or feature
4. Ask the user

### 3. Identify standards sources

Look for `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `AGENTS.md`, or similar. Also carry the Fowler smell baseline:

- Mysterious Name
- Duplicated Code
- Feature Envy
- Data Clumps
- Primitive Obsession
- Repeated Switches
- Shotgun Surgery
- Divergent Change
- Speculative Generality
- Message Chains
- Middle Man
- Refused Bequest

Repo standards override the baseline. Each smell is a judgement call, not a hard violation.

### 4. Spawn parallel subagents

Use the `task` tool with `subagent_type=general` for both.

**Standards subagent prompt:**

- Full diff command and commit list
- Standards sources and the full smell baseline
- "Report per file/hunk: (a) documented-standard violations with citation; (b) baseline smells with name and quoted hunk. Distinguish hard violations from judgement calls. Skip tooling-enforced issues. Under 400 words."

**Spec subagent prompt:**

- Diff command and commit list
- Spec contents
- "Report: (a) missing/partial requirements; (b) scope creep; (c) implemented-but-wrong behavior. Quote the spec line for each. Under 400 words."

### 5. Aggregate

Present findings under `## Standards` and `## Spec` headings. Do not merge or rerank.
End with a one-line summary: total findings per axis and worst issue within each.
