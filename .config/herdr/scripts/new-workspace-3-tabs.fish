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

function shell_quote
    python3 -c 'import shlex, sys; print(shlex.quote(sys.argv[1]))' "$argv[1]"
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

set -l workspace_label (basename -- "$cwd")
if set -q HERDR_3TAB_WORKSPACE_LABEL
    set workspace_label "$HERDR_3TAB_WORKSPACE_LABEL"
end

set -l source_workspace none
if set -q HERDR_ACTIVE_WORKSPACE_ID
    set source_workspace "$HERDR_ACTIVE_WORKSPACE_ID"
end

set -l tab1_label agent
set -l tab2_label git
set -l tab3_label status
if set -q HERDR_3TAB_TAB1_LABEL
    set tab1_label "$HERDR_3TAB_TAB1_LABEL"
end
if set -q HERDR_3TAB_TAB2_LABEL
    set tab2_label "$HERDR_3TAB_TAB2_LABEL"
end
if set -q HERDR_3TAB_TAB3_LABEL
    set tab3_label "$HERDR_3TAB_TAB3_LABEL"
end

set -l git_user (git -C "$cwd" config user.name 2>/dev/null)
if test -z "$git_user"
    set git_user (git config --global user.name 2>/dev/null)
end
if test -z "$git_user"
    set git_user "$USER"
end

set -l branch (git -C "$cwd" branch --show-current 2>/dev/null)
if test -z "$branch"
    set branch (git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
end
if test -z "$branch"
    set branch none
end

set -l agent_cmd 'if command -v opencode >/dev/null 2>&1; then exec opencode; elif command -v claude >/dev/null 2>&1; then exec claude; else echo "No agent CLI found: install opencode or claude."; fi'
set -l git_cmd 'if command -v lazygit >/dev/null 2>&1; then exec lazygit; else echo "lazygit not found. Install it with pacman or your AUR helper."; fi'
set -l cmd1 "$agent_cmd"
set -l cmd2 "$git_cmd"
if set -q HERDR_3TAB_CMD1
    set cmd1 "$HERDR_3TAB_CMD1"
end
if set -q HERDR_3TAB_CMD2
    set cmd2 "$HERDR_3TAB_CMD2"
end

set -l workspace_json (herdr workspace create --cwd "$cwd" --label "$workspace_label" --focus)
if test $status -ne 0
    echo "Could not create Herdr workspace."
    exit 1
end
set -l workspace_id (printf '%s\n' "$workspace_json" | json_get "result.workspace.workspace_id")
set -l tab1_id (printf '%s\n' "$workspace_json" | json_get "result.tab.tab_id")
set -l pane1_id (printf '%s\n' "$workspace_json" | json_get "result.root_pane.pane_id")

herdr tab rename "$tab1_id" "$tab1_label" >/dev/null
set -l tab2_json (herdr tab create --workspace "$workspace_id" --cwd "$cwd" --label "$tab2_label" --no-focus)
set -l pane2_id (printf '%s\n' "$tab2_json" | json_get "result.root_pane.pane_id")
set -l tab3_json (herdr tab create --workspace "$workspace_id" --cwd "$cwd" --label "$tab3_label" --no-focus)
set -l pane3_id (printf '%s\n' "$tab3_json" | json_get "result.root_pane.pane_id")

set -l status_script "$HOME/.config/herdr/scripts/workspace-status.fish"
if set -q HERDR_3TAB_STATUS_SCRIPT
    set status_script "$HERDR_3TAB_STATUS_SCRIPT"
end
set -l status_cmd (string join '' \
    'clear; HERDR_STATUS_GIT_USER=' (shell_quote "$git_user") \
    ' HERDR_STATUS_CWD=' (shell_quote "$cwd") \
    ' HERDR_STATUS_BRANCH=' (shell_quote "$branch") \
    ' HERDR_STATUS_WORKSPACE_LABEL=' (shell_quote "$workspace_label") \
    ' HERDR_STATUS_WORKSPACE_ID=' (shell_quote "$workspace_id") \
    ' HERDR_STATUS_SOURCE_WORKSPACE=' (shell_quote "$source_workspace") \
    ' ' (shell_quote "$status_script"))
set -l cmd3 "$status_cmd"
if set -q HERDR_3TAB_CMD3
    set cmd3 "$HERDR_3TAB_CMD3"
end

herdr pane run "$pane1_id" "$cmd1" >/dev/null
herdr pane run "$pane2_id" "$cmd2" >/dev/null
herdr pane run "$pane3_id" "$cmd3" >/dev/null
herdr workspace focus "$workspace_id" >/dev/null

echo "Created workspace $workspace_label with agent, git, and status tabs."
