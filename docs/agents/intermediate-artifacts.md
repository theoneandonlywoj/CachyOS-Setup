# Intermediate artifacts

This repo uses a single naming convention for session and intermediate artifacts so multiple
features can be worked on at the same time and every working file is easy to spot in the editor.

## The pattern

Every intermediate artifact follows:

```text
_NAME_<feature-slug>
```

- **Leading underscore** — intermediate and working files start with `_`, so they sort above
  durable project files and are easy to spot in a file explorer.
- **`<feature-slug>`** — the short, lowercase, filesystem-safe identifier for the feature or
  effort the file belongs to, so artifacts for different features never collide.

The slug comes from the feature branch name, or from the topic when the work has no branch.

## Artifact naming table

| Artifact | File / folder |
| --- | --- |
| Feature glossary | `_CONTEXT_<feature>.md` |
| Grilling transcript | `_INTERVIEW_<feature>.md` |
| PR description draft | `_PR_<feature>.md` |
| Async questionnaire | `_QUESTIONNAIRE_<feature>.md` |
| Handoff document | `_HANDOFF_<feature>.md` |
| Research findings | `_RESEARCH_<feature>.md` |
| Architecture review report | `_ARCHITECTURE-REVIEW_<feature>-<timestamp>.html` |
| Prototype folder | `_prototype_<feature>/` |
| Wizard folder | `_wizard_<feature>/` |
| Debug evidence folder | `_debug_<feature>/` |
| Scenario artifact folder | `_scenarios_<feature>/` |
| Scenario document | `_scenarios_<feature>/_scenarios_<feature>.md` |
| Scenario PR draft | `_scenarios_<feature>/_PR_<feature>.md` |
| Scenario screenshots | `_scenarios_<feature>/_screenshots_<feature>/` |
| Scenario seed data | `_scenarios_<feature>/_seed-data_<feature>/` |

Folder names follow the same convention: `_scenarios_<feature>/`, `_screenshots_<feature>/`,
`_seed-data_<feature>/`, and `_research_<feature>/`.

## Rules

- Create the file lazily — only when there is something to write.
- Do not rename durable knowledge: ADRs in `docs/adr/`, the legacy root `CONTEXT.md`,
  `.out-of-scope/`, local tracker records under `.scratch/`, or teaching documents.
- If a legacy `CONTEXT.md` exists at the root, keep reading it for vocabulary, but write new
  feature terms to `_CONTEXT_<feature>.md`.
- Do not duplicate a meaning already captured in a durable artifact; reference it by path.
