#!/usr/bin/env fish
# === auto_ontology.fish ===
# Purpose: Install NVIDIA Auto Ontology (local compose stack) on CachyOS
# Author: theoneandonlywoj

echo "🚀 Starting Auto Ontology installation..."

# === 1. Check prerequisites ===
set -l engine
if command -q podman; and podman compose version >/dev/null 2>&1
    set engine podman
else if command -q docker; and docker compose version >/dev/null 2>&1
    set engine docker
else
    echo "❌ No compose provider found. Run ./podman.fish and ./podman_compose.fish first, then rerun ./auto_ontology.fish."
    exit 1
end
for tool in git openssl
    if not command -q $tool
        echo "❌ $tool is not installed (sudo pacman -S --needed $tool). Then rerun ./auto_ontology.fish."
        exit 1
    end
end
if not command -q uv
    echo "❌ uv is not installed. Run ./python_and_uv.fish first, then rerun ./auto_ontology.fish."
    exit 1
end

set -l ontology_dir "$HOME/auto-ontology"
if set -q AUTO_ONTOLOGY_DIR; and test -n "$AUTO_ONTOLOGY_DIR"
    set ontology_dir (path resolve -- "$AUTO_ONTOLOGY_DIR")
end
echo "📂 Checkout: $ontology_dir ($engine compose)"

# === 2. Clone or fast-forward the checkout ===
if test -e "$ontology_dir/.git"
    set -l origin (git -C "$ontology_dir" remote get-url origin 2>/dev/null)
    if not string match -qr '^(https://github\.com/|git@github\.com:|ssh://git@github\.com/)NVIDIA/auto-ontology(\.git)?/?$' -- "$origin"
        echo "❌ $ontology_dir has a different origin: $origin"
        echo "💡 Resolve it by hand, then rerun: ./auto_ontology.fish"
        exit 1
    end
    set -l existing_status (git -C "$ontology_dir" status --porcelain)
    if test $status -ne 0; or test -n "$existing_status"
        echo "❌ $ontology_dir has local changes, or git could not read it."
        echo "💡 Resolve it by hand, then rerun: ./auto_ontology.fish"
        exit 1
    end
    git -C "$ontology_dir" pull --ff-only
    if test $status -ne 0
        echo "❌ Could not fast-forward $ontology_dir. Rerun: ./auto_ontology.fish"
        exit 1
    end
else if test -e "$ontology_dir"
    echo "❌ $ontology_dir exists but is not a Auto Ontology checkout. Resolve it by hand, then rerun: ./auto_ontology.fish"
    exit 1
else
    mkdir -p (dirname "$ontology_dir"); and git clone --depth 1 https://github.com/NVIDIA/auto-ontology.git "$ontology_dir"
    if test $status -ne 0
        echo "❌ Clone failed. Rerun: ./auto_ontology.fish"
        exit 1
    end
end

# === 3. Seed .env (only when it is missing) ===
set -l env_file "$ontology_dir/.env"
set -l stray "$ontology_dir"/.env.seed.*.local
if test (count $stray) -gt 0
    rm -f -- $stray
end

if test -e "$env_file"
    echo "✅ Keeping the existing $env_file"
else
    set -l example "$ontology_dir/.env.example"
    if not test -f "$example"
        echo "❌ $example not found. Check the checkout, then rerun: ./auto_ontology.fish"
        exit 1
    end

    # Collect the values first: KEY=value entries, never printed.
    set -l auth_secret (openssl rand -base64 32)
    if test $status -ne 0; or test -z "$auth_secret"
        echo "❌ Failed to generate AUTH_SECRET. Rerun: ./auto_ontology.fish"
        exit 1
    end
    set -l keys AUTH_SECRET
    set -l values "$auth_secret"
    if not string match -qr '^APP_URL=.' <"$example"
        set -a keys APP_URL
        set -a values "http://localhost:3000"
    end

    if test -t 0
        echo "Press Enter to keep a placeholder."
        # Format: key|label|hidden
        for entry in \
                "AUTO_ONTOLOGY_ADMIN_EMAIL|Admin email|" \
                "AUTO_ONTOLOGY_ADMIN_PASSWORD|Admin password|yes" \
                "DEFAULT_MODELS_API_KEY|NVIDIA API key (nvapi-...)|yes" \
                "POSTGRES_PASSWORD|Postgres password|yes" \
                "CONNECTION_STRINGS|Connection strings (optional)|yes"
            set -l fields (string split '|' -- $entry)
            set -l value
            if test -n "$fields[3]"
                read -s -P "$fields[2] (hidden): " value
            else
                read -P "$fields[2]: " value
            end
            if test $status -ne 0
                echo "❌ Input aborted; no .env was written. Rerun: ./auto_ontology.fish"
                exit 1
            end
            if test -z "$value"
                continue
            end
            # Compose reads $, # and spaces literally only inside single quotes.
            if string match -qr "['\\\\]" -- "$value"
                echo "⚠️  $fields[1] contains a quote or backslash; keeping the placeholder. Edit $env_file later."
                continue
            end
            if string match -qr '[^A-Za-z0-9_./:@%+=,?&~-]' -- "$value"
                set value "'$value'"
            end
            set -a keys $fields[1]
            set -a values "$value"
        end
    end

    # Write a private temporary file, then publish it in one step.
    set -l old_umask (umask)
    umask 077
    set -l seed "$ontology_dir/.env.seed.$fish_pid.local"
    cp "$example" "$seed"
    if test $status -ne 0
        rm -f -- "$seed"
        echo "❌ Failed to create $seed. Rerun: ./auto_ontology.fish"
        exit 1
    end
    set -l lines (cat "$example")
    for i in (seq (count $keys))
        set -l hit
        for n in (seq (count $lines))
            if string match -q -- "$keys[$i]=*" "$lines[$n]"
                set lines[$n] "$keys[$i]=$values[$i]"
                set hit yes
            end
        end
        if test -z "$hit"
            set -a lines "$keys[$i]=$values[$i]"
        end
    end
    printf '%s\n' $lines >"$seed"
    if test $status -ne 0
        rm -f -- "$seed"
        echo "❌ Failed to write $seed. Rerun: ./auto_ontology.fish"
        exit 1
    end
    if not test -e "$env_file"
        mv -n -- "$seed" "$env_file"
    end
    if test -e "$seed"
        rm -f -- "$seed"
        echo "❌ Failed to publish $env_file. Rerun: ./auto_ontology.fish"
        exit 1
    end
    umask $old_umask
    echo "✅ Created $env_file"
end

# Names only, never values: keys that still hold an upstream example value.
set -l placeholders (string replace -rf '^([A-Z_]+)=.*(change-me|myverylongsecret123|admin@nvidia\.com|autoontologypassword123|nvapi-your-api-key-here|user:password@).*$' '$1' <"$env_file")
if test (count $placeholders) -gt 0
    echo "⚠️  Still to edit in $env_file:"
    printf '   %s\n' $placeholders
end

# === 4. Start the stack ===
cd "$ontology_dir"; or exit 1
$engine compose up -d --build
if test $status -ne 0
    echo "❌ compose up failed. Logs: cd $ontology_dir; and $engine compose logs"
    echo "💡 Rerun: ./auto_ontology.fish"
    exit 1
end

# === 5. Verify the stack (up to 30 s) ===
echo "🧪 Waiting for http://localhost:3000..."
set -l ready
set -l deadline (math (date +%s) + 30)
while test (date +%s) -lt $deadline
    if curl -fsS --max-time 5 localhost:3000 >/dev/null 2>&1
        set ready yes
        break
    end
    sleep 2
end
if test -n "$ready"
    echo "✅ UI reachable at http://localhost:3000"
else
    echo "⚠️  The UI does not answer yet. Logs: cd $ontology_dir; and $engine compose logs"
end

echo
echo "✅ Auto Ontology setup complete!"
echo "💡 Stop, keep data: cd $ontology_dir; and $engine compose down"
echo "📚 Guide: docs/guide_auto_ontology.md"
exit 0
