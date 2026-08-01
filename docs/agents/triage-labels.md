# Triage label vocabulary

Every triaged issue carries exactly one category label and one state label.

## Category labels

- `bug` — something is broken
- `enhancement` — new feature or improvement

## State labels

- `needs-triage` — maintainer needs to evaluate
- `needs-info` — waiting on reporter for more information
- `ready-for-agent` — fully specified, ready for an agent
- `ready-for-human` — needs human implementation
- `wontfix` — will not be actioned

## State transitions

- Unlabeled → `needs-triage`
- `needs-triage` → `needs-info`, `ready-for-agent`, `ready-for-human`, or `wontfix`
- `needs-info` → `needs-triage` once the reporter replies
- Maintainer can override at any time

If state labels conflict, flag it and ask the maintainer before doing anything else.
