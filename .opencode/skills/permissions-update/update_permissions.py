#!/usr/bin/env python3
"""
Permission Update for OpenCode

Scans the OpenCode SQLite database for approved (completed) tool calls,
extracts patterns, and merges them into the global permission config.
"""

import json
import os
import re
import sqlite3
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

OPENCODE_DB = Path.home() / ".local" / "share" / "opencode" / "opencode.db"
OPENCODE_CONFIG = Path.home() / ".config" / "opencode" / "opencode.json"
BACKUP_DIR = Path.home() / ".config" / "opencode" / "backups"

# Commands that must never be auto-allowed
DANGEROUS_PATTERNS = {
    "rm -rf *",
    "rm -rf /",
    "git reset --hard*",
    "git push --force*",
    "git push -f*",
    "git checkout -- .",
    "git clean -f*",
    "sudo *",
    "chmod 777*",
    "dd if=*",
    "> /dev/sd*",
}


def extract_bash_patterns(command: str) -> set[str]:
    """Extract permission-friendly patterns from a bash command.

    Handles compound commands (&&, ||, |, ;) by splitting and extracting
    each sub-command's base tool. Returns a set of patterns.
    """
    if not command or not command.strip():
        return set()

    cmd = command.strip()

    # Skip dangerous commands
    for dangerous in DANGEROUS_PATTERNS:
        pat = dangerous.replace("*", "")
        if cmd.startswith(pat):
            return set()

    # Known tools that should get wildcard patterns
    WILDCARD_TOOLS = {
        "mix",
        "iex",
        "elixir",
        "erl",
        "rebar3",
        "git",
        "gh",
        "grep",
        "rg",
        "find",
        "fd",
        "ag",
        "ls",
        "cat",
        "head",
        "tail",
        "wc",
        "sort",
        "uniq",
        "tr",
        "mkdir",
        "cp",
        "mv",
        "touch",
        "rm",
        "chmod",
        "chown",
        "curl",
        "wget",
        "make",
        "cmake",
        "npm",
        "npx",
        "yarn",
        "pnpm",
        "bun",
        "python3",
        "python",
        "pip",
        "uvx",
        "docker",
        "docker-compose",
        "cargo",
        "rustc",
        "go",
        "sqlite3",
        "jq",
        "yq",
        "sed",
        "awk",
        "diff",
        "patch",
        "tar",
        "zip",
        "unzip",
        "gzip",
        "bzip2",
        "watchexec",
        "tmux",
        "tmuxp",
        "echo",
        "printf",
        "tee",
        "file",
        "stat",
        "realpath",
        "basename",
        "dirname",
        "readlink",
        "env",
        "test",
        "true",
        "false",
        "node",
        "deno",
        "opencode",
        "uv",
        "pip",
    }

    # Split compound commands on &&, ||, |, ;
    sub_cmds = re.split(r"\s*(?:&&|\|\||\||;)\s*", cmd)

    patterns = set()
    for sub in sub_cmds:
        sub = sub.strip()
        if not sub:
            continue

        # Strip leading cd ... && (already split), env vars, redirections
        # Remove leading env VAR=val assignments
        while re.match(r"^[A-Z_][A-Z_0-9]*=\S+\s+", sub):
            sub = re.sub(r"^[A-Z_][A-Z_0-9]*=\S+\s+", "", sub)

        # Strip leading "cd /path &&" if it wasn't split properly
        if sub.startswith("cd "):
            continue  # cd itself is harmless, skip it

        parts = sub.split()
        if not parts:
            continue

        base = parts[0]

        # Strip path prefix (e.g., /usr/bin/python3 -> python3)
        base = os.path.basename(base)

        # Strip ./ prefix
        if base.startswith("./"):
            base = base[2:]

        # Check against dangerous patterns
        is_dangerous = False
        for dangerous in DANGEROUS_PATTERNS:
            pat = dangerous.replace("*", "")
            if sub.startswith(pat):
                is_dangerous = True
                break
        if is_dangerous:
            continue

        if base in WILDCARD_TOOLS:
            patterns.add(f"{base} *")

    return patterns


def extract_file_glob(file_path: str) -> str | None:
    """Extract a glob pattern from a file path."""
    if not file_path:
        return None

    p = Path(file_path)
    ext = p.suffix
    if not ext:
        return None

    # Map extensions to glob patterns
    return f"**/*{ext}"


def query_tool_calls(db_path: Path) -> dict:
    """Query the OpenCode DB for all completed tool calls."""
    permissions = {
        "bash": set(),
        "edit": set(),
        "read": set(),
        "glob": set(),
    }

    if not db_path.exists():
        print(f"Database not found: {db_path}", file=sys.stderr)
        return permissions

    conn = sqlite3.connect(str(db_path))
    try:
        # Extract bash commands
        cursor = conn.execute("""
            SELECT data FROM part
            WHERE data LIKE '%"tool":"bash"%'
            AND data LIKE '%"status":"completed"%'
        """)
        for (row,) in cursor:
            try:
                data = json.loads(row)
                cmd = data.get("state", {}).get("input", {}).get("command", "")
                patterns = extract_bash_patterns(cmd)
                permissions["bash"].update(patterns)
            except (json.JSONDecodeError, KeyError):
                continue

        # Extract edit file patterns
        cursor = conn.execute("""
            SELECT data FROM part
            WHERE data LIKE '%"tool":"edit"%'
            AND data LIKE '%"status":"completed"%'
        """)
        for (row,) in cursor:
            try:
                data = json.loads(row)
                fp = data.get("state", {}).get("input", {}).get("filePath", "")
                glob = extract_file_glob(fp)
                if glob:
                    permissions["edit"].add(glob)
            except (json.JSONDecodeError, KeyError):
                continue

        # Extract read file patterns
        cursor = conn.execute("""
            SELECT data FROM part
            WHERE data LIKE '%"tool":"read"%'
            AND data LIKE '%"status":"completed"%'
        """)
        for (row,) in cursor:
            try:
                data = json.loads(row)
                fp = data.get("state", {}).get("input", {}).get("filePath", "")
                glob = extract_file_glob(fp)
                if glob:
                    permissions["read"].add(glob)
            except (json.JSONDecodeError, KeyError):
                continue

        # Extract glob patterns
        cursor = conn.execute("""
            SELECT data FROM part
            WHERE data LIKE '%"tool":"glob"%'
            AND data LIKE '%"status":"completed"%'
        """)
        for (row,) in cursor:
            try:
                data = json.loads(row)
                pattern = data.get("state", {}).get("input", {}).get("pattern", "")
                if pattern:
                    permissions["glob"].add(pattern)
            except (json.JSONDecodeError, KeyError):
                continue

    finally:
        conn.close()

    return permissions


def load_config() -> dict:
    """Load existing opencode config, handling JSONC comments."""
    if not OPENCODE_CONFIG.exists():
        return {}

    with open(OPENCODE_CONFIG) as f:
        content = f.read()

    # Strip JSONC comments
    lines = []
    for line in content.split("\n"):
        stripped = line.lstrip()
        if stripped.startswith("//"):
            continue
        if "//" in line:
            idx = line.find("//")
            before = line[:idx]
            if before.count('"') % 2 == 0:
                lines.append(before)
            else:
                lines.append(line)
        else:
            lines.append(line)

    return json.loads("\n".join(lines))


def backup_config():
    """Create a timestamped backup of the existing config."""
    if not OPENCODE_CONFIG.exists():
        return

    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = BACKUP_DIR / f"opencode.json.backup_{timestamp}"

    with open(OPENCODE_CONFIG) as src:
        with open(backup_path, "w") as dst:
            dst.write(src.read())

    print(f"  Backup created: {backup_path}")


def merge_permissions(existing: dict, new: dict) -> tuple[dict, dict]:
    """
    Merge new permissions into existing config.
    Never overrides 'ask' or 'deny' rules.
    Returns (merged, additions_only).
    """
    merged = {}
    additions = {}

    for tool in ("bash", "edit", "read", "glob"):
        existing_tool = existing.get(tool, {})
        new_patterns = new.get(tool, set())

        # Normalize existing to dict
        if isinstance(existing_tool, str):
            # Single value like "ask" — preserve it as-is
            merged[tool] = existing_tool
            continue

        tool_merged = dict(existing_tool)
        tool_additions = {}

        for pattern in sorted(new_patterns):
            if pattern not in tool_merged:
                tool_merged[pattern] = "allow"
                tool_additions[pattern] = "allow"

        if tool_merged:
            merged[tool] = tool_merged
        if tool_additions:
            additions[tool] = tool_additions

    # Preserve any other keys in existing permissions
    for key, value in existing.items():
        if key not in merged:
            merged[key] = value

    return merged, additions


def main():
    print("=" * 60)
    print("  OpenCode Permissions Update")
    print("=" * 60)
    print()

    # Step 1: Extract from DB
    print("Scanning session history...")
    new_perms = query_tool_calls(OPENCODE_DB)

    total = sum(len(v) for v in new_perms.values())
    print(f"  Found {total} unique patterns across all sessions")

    for tool in ("bash", "edit", "read", "glob"):
        patterns = new_perms[tool]
        if patterns:
            print(f"\n  {tool} ({len(patterns)} patterns):")
            for p in sorted(patterns):
                print(f"    {p}")

    if total == 0:
        print("\nNo approved tool calls found in session history.")
        return 0

    # Step 2: Load existing config
    print("\n" + "-" * 60)
    print("Loading existing config...")
    config = load_config()
    existing_perms = config.get("permission", {})

    # Step 3: Compute diff
    merged, additions = merge_permissions(existing_perms, new_perms)

    additions_total = sum(len(v) for v in additions.values())
    if additions_total == 0:
        print("\nAll patterns are already in config. Nothing to add.")
        return 0

    print(f"\n{additions_total} NEW patterns to add:")
    for tool, patterns in sorted(additions.items()):
        print(f"\n  {tool}:")
        for pattern, action in sorted(patterns.items()):
            print(f"    + {pattern}: {action}")

    # Step 4: Confirm
    print("\n" + "=" * 60)
    response = input("Apply these permissions? [y/N]: ").strip().lower()
    if response != "y":
        print("Aborted.")
        return 0

    # Step 5: Backup and write
    print("\nBacking up config...")
    backup_config()

    config["permission"] = merged
    OPENCODE_CONFIG.parent.mkdir(parents=True, exist_ok=True)

    with open(OPENCODE_CONFIG, "w") as f:
        json.dump(config, f, indent=2)
        f.write("\n")

    print(f"\nConfig updated: {OPENCODE_CONFIG}")
    print("Restart OpenCode to apply changes.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
