#!/usr/bin/env fish

printf 'Hello, %s!\n\n' (set -q HERDR_STATUS_GIT_USER; and echo "$HERDR_STATUS_GIT_USER"; or echo there)
printf 'Location: %s\n' (set -q HERDR_STATUS_CWD; and echo "$HERDR_STATUS_CWD"; or echo unknown)
printf 'Branch: %s\n' (set -q HERDR_STATUS_BRANCH; and echo "$HERDR_STATUS_BRANCH"; or echo none)
printf 'Workspace: %s (%s)\n' \
    (set -q HERDR_STATUS_WORKSPACE_LABEL; and echo "$HERDR_STATUS_WORKSPACE_LABEL"; or echo unknown) \
    (set -q HERDR_STATUS_WORKSPACE_ID; and echo "$HERDR_STATUS_WORKSPACE_ID"; or echo unknown)
printf 'Source workspace: %s\n' (set -q HERDR_STATUS_SOURCE_WORKSPACE; and echo "$HERDR_STATUS_SOURCE_WORKSPACE"; or echo none)
