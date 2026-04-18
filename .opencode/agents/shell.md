description: Fish shell script development — .fish files, functions, completions

permission:
  edit:
    "**/*.fish": allow
    "**/completions/**/*": allow
    "**/functions/**/*": allow
    "**/conf.d/**/*": allow
  bash:
    fish: allow
    fisher: allow
    omf: allow
    mise: allow
    just: allow
    rg: allow
    sed: allow
    awk: allow
    chmod: allow
    sudo: ask
  glob:
    "**/*.fish": allow

mcp:
  sequential-thinking: inherit
  filesystem: inherit
  memory: inherit
  fetch: inherit
