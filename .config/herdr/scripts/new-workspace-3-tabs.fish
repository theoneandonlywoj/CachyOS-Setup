#!/usr/bin/env fish

function json_get
    python3 -c '
import json
import sys

data = json.load(sys.stdin)
value = data
for part in sys.argv[1].split("."):
    value = value[part]
print(value)
' "$argv[1]"
end

set -l config_file "$HOME/.config/herdr/three-tab-workspace.fish"
if set -q HERDR_3TAB_CONFIG
    set config_file "$HERDR_3TAB_CONFIG"
end
if test -f "$config_file"
    source "$config_file"
end

set -l cwd "$PWD"
if set -q HERDR_3TAB_CWD
    set cwd "$HERDR_3TAB_CWD"
else if set -q HERDR_ACTIVE_PANE_CWD
    set cwd "$HERDR_ACTIVE_PANE_CWD"
end

if not set -q HERDR_3TAB_CWD
    read --line --command "$cwd" --prompt-str "Workspace directory: " cwd
    if test $status -ne 0
        exit 1
    end
end
if not test -d "$cwd"
    echo "Working directory does not exist: $cwd"
    exit 1
end

set -l workspace_label (basename -- "$cwd")
if set -q HERDR_3TAB_WORKSPACE_LABEL
    set workspace_label "$HERDR_3TAB_WORKSPACE_LABEL"
end

set -l tab1_label agent
set -l tab2_label git
set -l tab3_label status
set -l tab4_label agent-low-effort
if set -q HERDR_3TAB_TAB1_LABEL
    set tab1_label "$HERDR_3TAB_TAB1_LABEL"
end
if set -q HERDR_3TAB_TAB2_LABEL
    set tab2_label "$HERDR_3TAB_TAB2_LABEL"
end
if set -q HERDR_3TAB_TAB3_LABEL
    set tab3_label "$HERDR_3TAB_TAB3_LABEL"
end
if set -q HERDR_3TAB_TAB4_LABEL
    set tab4_label "$HERDR_3TAB_TAB4_LABEL"
end

set -l workspace_json (herdr workspace create --cwd "$cwd" --label "$workspace_label" --focus)
if test $status -ne 0
    echo "Could not create Herdr workspace."
    exit 1
end
set -l workspace_id (printf '%s\n' "$workspace_json" | json_get "result.workspace.workspace_id")
set -l tab1_id (printf '%s\n' "$workspace_json" | json_get "result.tab.tab_id")

herdr tab rename "$tab1_id" "$tab1_label" >/dev/null
herdr tab create --workspace "$workspace_id" --cwd "$cwd" --label "$tab2_label" --no-focus >/dev/null
herdr tab create --workspace "$workspace_id" --cwd "$cwd" --label "$tab3_label" --no-focus >/dev/null
herdr tab create --workspace "$workspace_id" --cwd "$cwd" --label "$tab4_label" --no-focus >/dev/null

herdr workspace focus "$workspace_id" >/dev/null

echo "Created workspace $workspace_label with four tabs."
