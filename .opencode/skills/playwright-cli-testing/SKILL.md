---
name: playwright-cli-testing
description: Use Playwright CLI for Phoenix, IEx, Bun, JavaScript, or TypeScript browser verification, branching-scenario analysis, frontend evidence, and workflow comparisons.
---

# Playwright CLI Testing

Use this skill when a Phoenix, IEx, Bun, JavaScript, or TypeScript application needs browser verification, exhaustive branch analysis, frontend screenshots, or a `/branching-scenarios` run.

Read `_CONTEXT_<feature>.md` and the relevant ADRs before acting. The target repository is the repository containing the application, not this setup repository.

## Tool Boundary

- Use the `playwright-cli` executable for browser interaction. Prefer literal commands such as `open`, `snapshot`, `click`, `fill`, `press`, `select`, `wait`, `screenshot`, and `console`.
- Generate the same CLI commands in the scenario artifact so a human can follow them.
- Use a narrowly scoped Playwright JS/TS helper only when the CLI cannot express a required assertion or data operation. Keep the helper browser-driven; do not replace the browser seam with direct application calls.
- Run Chromium by default. Use another browser only when the target feature has a configured browser-specific requirement.

## Preconditions

1. Confirm the current checkout is a feature or ticket branch. Stop on `main`, `master`, detached HEAD, or another non-feature branch and ask the user to check out the target branch.
2. Derive a short lowercase filesystem-safe feature slug from the branch name.
3. Compare the old workflow from `main`, or `master` when `main` does not exist, with committed current-branch code plus staged index changes. List unstaged files and ask whether to continue. If the user continues, exclude unstaged files from the comparison while noting that the running server may still serve them.
4. Check that `playwright-cli` is installed. If it is missing, inspect the target repository's Makefile, documentation, and scripts for an installation command and suggest it without running it. Do the same for missing browser binaries and Mermaid tooling.
5. Inspect the target repository's Makefile and project configuration for Phoenix/IEx or Bun server commands. Check reachability using discovered URLs, ports, and safe project defaults. If offline, show the discovered start command; if no command is discoverable, request configuration. Never guess or launch a destructive command.

## Seed Data

- Append newly generated, uniquely identifiable records to the existing local development database. Never clear existing data or replay a previous seed.
- Seed every scenario independently so one scenario's mutations cannot contaminate another. Show the complete seed code at the top of that scenario and link to its executable file.
- Inspect existing seed files, factories, Makefile targets, and database commands first. Use the target application's native mechanism.
- When no suitable mechanism exists, show a seed proposal with a step-by-step explanation, identify the scenario it supports, ask for permission, and execute only after approval.
- Use `.exs` for Elixir, `.js` for JavaScript, and `.ts` for TypeScript when that is the target project's native language.
- Keep generated seed values complete only when they are non-sensitive. Redact uncertain or sensitive values before placing them in artifacts.

## Branch Analysis

- Inventory every reachable conditional, error, and data-flow branch in the implementation.
- Include a private function whenever it changes an observable result, regardless of whether it appears in `with` or `|>`.
- Label graph nodes with the module, function name, declared parameters and types when available, and source file line ranges. For untyped JavaScript, preserve an untyped signature instead of inferring a type.
- Test only the new workflow with Playwright. The old workflow is static comparison and documentation input.
- Mark branches that cannot be reached through the browser as `uncovered by Playwright`, explain why, and do not use direct function or API calls to claim coverage.

## Execution And Evidence

- Use Chromium and execute scenarios in stable source-location and branch-traversal order.
- Record every state-changing step as the literal CLI command, inputs, resulting URL or state, relevant DOM snapshot, console/network errors, and result.
- Capture PNG screenshots for frontend state changes. Use the current viewport for intermediate captures and full-page capture for final results when supported.
- Reuse configured Playwright session state when available. Otherwise pause for interactive login. If automation fails, give explicit manual steps, wait for confirmation, and then continue the same scenario. Never write credentials, cookies, or tokens to artifacts.
- Use configured development or sandbox integrations for emails, payments, webhooks, and other external effects. Block an unsafe production effect and document the missing safe configuration.
- Redact secrets, tokens, cookies, authorization headers, and uncertain sensitive values. For safe examples preserve a useful prefix and suffix with `...`; never publish a complete uncertain value.

## Scenario Artifact

Keep the artifact untracked unless the user explicitly asks otherwise:

```text
_scenarios_<feature-slug>/
  _PR_<feature-slug>.md
  _scenarios_<feature-slug>.md
  _screenshots_<feature-slug>/<scenario-slug>/001.png
  _seed-data_<feature-slug>/001_<scenario-slug>.exs|js|ts
```

Write `_scenarios_<feature-slug>.md` in this order:

1. Metadata: feature, branches/commits, server, seed policy, and unstaged-file warning.
2. Focused Mermaid workflow-delta graphs for sensitive changes. Put them before the old and new workflow sections and use `...` for unchanged surrounding steps.
3. Old workflow from the base branch.
4. New workflow from committed plus staged current-branch code.
5. `TLDR` with the differences.
6. Code-branch inventory and Playwright coverage status.
7. One section per scenario with a 2-5 sentence description, complete seed code and file link, initial action/input, intermediate inputs/outputs, final action/result, literal Playwright CLI commands, step evidence, and screenshot links.
8. Findings grouped as Critical, Warning, and Info. Explain each finding, name the related source file and lines, then provide an example minimal-change remediation prompt for an LLM agent. Show the prompt but do not execute it.

Use stable zero-padded scenario numbers and slugified names for seed files, screenshot folders, graph references, and document headings. Validate every Mermaid graph with available repository tooling.

## Failure Recovery

Run all scenarios in order even when one fails, recording the failure and continuing with the remaining scenarios. After the initial run:

1. Explain each failed scenario and show an example prompt proposing the smallest likely change, with the scenario name and affected file.
2. Stop and wait for the user to apply the prompt separately.
3. Ask permission to retest the named failed scenario.
4. If it passes, rerun every scenario from the beginning.
5. Replace prior result evidence and screenshots during the full rerun so no stale captures remain.

## PR Review And Publication

- Leave `_scenarios_<feature-slug>/` untracked.
- Write `_scenarios_<feature-slug>/_PR_<feature-slug>.md` containing the complete proposed `_scenarios_<feature-slug>.md` body and relative local screenshot paths.
- Ask the user to accept the draft or edit it. If edited, reread it and ask for acceptance again.
- After acceptance, generate the GitHub CLI/API command that uploads screenshots as viewable PR attachments, substitutes the returned URLs, and updates the current branch's PR body. If no PR exists, create one against `main`, or `master` when `main` does not exist.
- Derive a new PR title from the most recent matching feature PR in the target repository's five merged PR examples. Preserve existing PR metadata and change only the body.
- If GitHub authentication or upload fails, stop before changing the PR body and show the exact recovery command. Never publish a partial body with broken screenshot links.
