# Beginner's Guide to Bend 2

This guide covers Bend from [github.com/bendlang/bend](https://github.com/bendlang/bend).
The repository's README documents an official installer, which supports Linux on x86_64 and arm64.

## What this script installs

`bend.fish` runs the installer documented in the upstream repository README:
`https://bend-lang.com/install.sh`. It requires `curl`; it does not need Bun,
Git, or a source checkout. (If you want Bun separately for development, see
[Mise's Bun backend](https://mise.jdx.dev/).)

## Install

From the root of this setup repository, run:

```sh
chmod +x bend.fish
./bend.fish
```

The script downloads the official installer, runs it and adds `~/.bend/bin` to
the Fish PATH. Open a new terminal and verify:

```sh
bend version
```

To update Bend later, rerun `./bend.fish`.

## Start exploring

Read the built-in guide and version information:

```sh
bend guide
bend version
```

Create a `.bend` file using examples from the guide, then run it with:

```sh
bend hello.bend
```

Bend is under active development, so consult the upstream README and built-in
guide for current syntax and CLI options.

## Common maintenance

Use the official upstream installation instructions to update or uninstall
Bend; the exact mechanism may change as the project evolves.

## Troubleshooting

- **`bend: command not found` after install:** open a new terminal and ensure
  the install location is on `PATH`. See the upstream install instructions.
- **Installer fails:** verify network access and review the current upstream
  README for updated installation directions.
- **An old tutorial command does not work:** run `bend guide` and check the
  upstream README; Bend is actively developed and its CLI can change.
