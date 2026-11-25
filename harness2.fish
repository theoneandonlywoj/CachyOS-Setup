#!/usr/bin/env fish
# === harness2.fish ===
# Purpose: Install or update Harness2 (recursive agent harness) via git and uv on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Harness2 installation..."

# === 1. Check prerequisites ===
if not command -q uv
    echo "❌ uv is not installed. Run ./python_and_uv.fish first, then rerun ./harness2.fish."
    exit 1
end
if not command -q git
    echo "❌ git is not installed (sudo pacman -S --needed git). Then rerun ./harness2.fish."
    exit 1
end

set -l harness2_dir "$HOME/Developer/harness2"
if set -q HARNESS2_DIR; and test -n "$HARNESS2_DIR"
    set harness2_dir (path resolve -- "$HARNESS2_DIR")
end

# === 2. Clone or fast-forward the checkout ===
if test -e "$harness2_dir/.git"
    set -l origin (git -C "$harness2_dir" remote get-url origin 2>/dev/null)
    if not string match -qr '^(https://github\.com/|git@github\.com:|ssh://git@github\.com/)google-research/harness2(\.git)?/?$' -- "$origin"
        echo "❌ $harness2_dir has a different origin: $origin"
        echo "💡 Resolve it by hand, then rerun: ./harness2.fish"
        exit 1
    end
    set -l existing_status (git -C "$harness2_dir" status --porcelain)
    if test $status -ne 0; or test -n "$existing_status"
        echo "❌ $harness2_dir has local changes, or git could not read it."
        echo "💡 Resolve it by hand, then rerun: ./harness2.fish"
        exit 1
    end
    git -C "$harness2_dir" pull --ff-only
    if test $status -ne 0
        echo "❌ Could not fast-forward $harness2_dir. Rerun: ./harness2.fish"
        exit 1
    end
else if test -e "$harness2_dir"
    echo "❌ $harness2_dir exists but is not a Harness2 checkout. Resolve it by hand, then rerun: ./harness2.fish"
    exit 1
else
    mkdir -p (dirname "$harness2_dir"); and git clone --depth 1 https://github.com/google-research/harness2.git "$harness2_dir"
    if test $status -ne 0
        echo "❌ Clone failed. Rerun: ./harness2.fish"
        exit 1
    end
end

# === 3. Create the Python environment and install Harness2 ===
set -l venv "$harness2_dir/.venv"
if not test -x "$venv/bin/python"
    # --allow-existing: an interrupted run may have left a partial .venv.
    uv venv --allow-existing --python 3.12 "$venv"
    if test $status -ne 0
        echo "❌ Failed to create the Python environment. Rerun: ./harness2.fish"
        exit 1
    end
end

cd "$harness2_dir"; or exit 1
uv pip install --python "$venv/bin/python" -e '.[render]'
if test $status -ne 0
    echo "❌ Harness2 installation failed. Rerun: ./harness2.fish"
    exit 1
end

# === 4. Link the CLIs into ~/.local/bin ===
mkdir -p "$HOME/.local/bin"
if test $status -ne 0
    echo "❌ Failed to create ~/.local/bin."
    exit 1
end

# fish_add_path returns 1 when the directory is already present. Only treat a
# failed addition as an error when the directory is not already on PATH.
if not contains -- "$HOME/.local/bin" $PATH
    fish_add_path -U "$HOME/.local/bin"
    if test $status -ne 0
        echo "❌ Failed to add ~/.local/bin to the Fish PATH."
        exit 1
    end
end

for cli in harness2 harness2-judge harness2-report harness2-setup harness2-check harness2-demo
    set -l target "$venv/bin/$cli"
    set -l link "$HOME/.local/bin/$cli"
    if not test -x "$target"
        echo "❌ Expected CLI was not installed: $target"
        exit 1
    end
    if test -L "$link"; and test (readlink "$link") = "$target"
        echo "✅ $cli is already linked."
    else if test -e "$link" -o -L "$link"
        echo "⚠️  Leaving the existing $link untouched. Use directly: $target"
    else
        ln -s "$target" "$link"
        if test $status -ne 0
            echo "❌ Failed to link $link. Rerun: ./harness2.fish"
            exit 1
        end
        echo "🔗 Linked $link"
    end
end

# === 5. Verify installation ===
echo "🧪 Verifying installation..."
"$venv/bin/harness2" --help >/dev/null; and "$venv/bin/harness2-demo" --help >/dev/null
if test $status -ne 0
    echo "❌ Harness2 installation verification failed."
    exit 1
end

echo
echo "✅ Harness2 setup complete: $harness2_dir"
echo "💡 Local demo (no credentials): cd $harness2_dir; and harness2-demo --output runs/demo --k 2"
echo "💡 Model settings: copy .env.example to .env there once, then edit it"
echo "💡 Authentication: gcloud auth application-default login (./google_cloud_sdk.fish)"
