#!/usr/bin/env fish
# === github_cli.fish ===
# Purpose: Install GitHub CLI (gh) on CachyOS (Arch Linux)
# Author: theoneandonlywoj

echo "🚀 Starting GitHub CLI (gh) installation..."
echo

# === 1. Install GitHub CLI ===
sudo pacman -S --needed --noconfirm github-cli
if test $status -ne 0
    echo "❌ Failed to install GitHub CLI. Rerun: ./github_cli.fish"
    exit 1
end

# === 2. Verify installation ===
echo "🧪 Verifying installation..."

if command -v gh > /dev/null
    set installed_version (gh --version | head -n1 | awk '{print $3}')
    echo "✅ GitHub CLI installed successfully: v$installed_version"
else
    echo "❌ GitHub CLI installation failed. Please check the installation method."
    exit 1
end

# === 3. Set up completion ===
echo "🔧 Setting up shell completion..."

# Fish completion
if test -d /usr/share/fish/vendor_completions.d/
    sudo mkdir -p /usr/share/fish/vendor_completions.d/
    gh completion -s fish | sudo tee /usr/share/fish/vendor_completions.d/gh.fish > /dev/null
end

# Also set up for current user
mkdir -p ~/.config/fish/completions
gh completion -s fish > ~/.config/fish/completions/gh.fish

if test $status -eq 0
    echo "✅ Fish completion installed"
else
    echo "⚠️  Could not install Fish completion"
end

# === 4. Authenticate (optional) ===
echo "🔐 Authentication setup (optional)..."
echo
echo "💡 To authenticate with GitHub, run:"
echo "   gh auth login"
echo
echo "   This will allow you to:"
echo "   - Create and clone repositories"
echo "   - Create issues and pull requests"
echo "   - View and manage notifications"
echo "   - And much more!"

# === 5. Optional gh-stack extension ===
echo
if test -t 0
    read -l -P "Install/update the github/gh-stack extension? [y/N] " install_stack
    if test "$install_stack" = "y" -o "$install_stack" = "Y"
        if not gh auth status >/dev/null 2>&1
            echo "⚠️  gh-stack skipped: run gh auth login, then rerun ./github_cli.fish"
        else
            if gh extension list 2>/dev/null | grep -Fq github/gh-stack
                gh extension upgrade gh-stack
            else
                gh extension install github/gh-stack
            end
            if test $status -ne 0
                echo "❌ gh-stack install/update failed. Rerun: ./github_cli.fish"
                exit 1
            end
            echo "✅ gh-stack ready"
        end
    end
else
    echo "ℹ No terminal: gh-stack skipped."
end

# === 6. Cheatsheet ===
echo
echo "════════════════════════════════════════════════════════"
echo "📘 gh CLI cheatsheet — common operations"
echo "════════════════════════════════════════════════════════"
echo
echo "🔐 Auth"
echo "   gh auth status                       # check login state"
echo "   gh auth login                        # log in"
echo
echo "📁 Repos"
echo "   gh repo create my-repo --public      # create a new repo"
echo "   gh repo clone owner/repo             # clone a repo"
echo "   gh repo view --web                   # open repo in browser"
echo "   gh repo fork owner/repo --clone      # fork + clone"
echo
echo "🔀 Pull requests"
echo "   gh pr list                           # list open PRs"
echo "   gh pr status                         # PRs relevant to you"
echo "   gh pr create --fill                  # create PR from current branch"
echo "   gh pr view 123 --web                 # open PR #123 in browser"
echo "   gh pr checkout 123                   # check out PR #123 locally"
echo "   gh pr merge 123 --squash             # squash-merge PR #123"
echo "   gh pr diff 123                       # view PR #123's diff"
echo "   gh pr review 123 --approve           # approve PR #123"
echo
echo "🐞 Issues"
echo "   gh issue list                        # list open issues"
echo "   gh issue create --title \"Bug\" --body \"...\"  # create an issue"
echo "   gh issue close 42                    # close issue #42"
echo
echo "⚙️  Workflows / CI"
echo "   gh run list                          # list recent workflow runs"
echo "   gh run watch                         # watch the latest run live"
echo "   gh workflow run deploy.yml           # trigger a workflow"
echo
echo "🧩 Extensions"
echo "   gh extension list                    # list installed extensions"
echo "   gh extension upgrade --all           # upgrade all extensions"
echo
echo "────────────────────────────────────────────────────────"
echo "📚 gh-stack cheatsheet — stacked pull requests"
echo "────────────────────────────────────────────────────────"
echo
echo "🚀 Build a stack"
echo "   gh stack init                        # start a stack (interactive)"
echo "   gh stack init feat-auth feat-api     # start a stack with named branches"
echo "   gh stack add feat-ui                 # add a new branch on top"
echo "   gh stack add -Am \"Add login\"          # stage all + commit + auto-name branch"
echo
echo "📤 Push & submit"
echo "   gh stack push                        # push all branches in the stack"
echo "   gh stack submit                      # push + open/update PRs for the stack"
echo "   gh stack submit --auto               # submit without the interactive editor"
echo
echo "🔄 Keep in sync"
echo "   gh stack sync                        # fetch, rebase, push, sync PRs (one shot)"
echo "   gh stack sync --prune                # sync + delete branches for merged PRs"
echo "   gh stack rebase                      # cascade-rebase the whole stack"
echo "   gh stack rebase --continue           # resume rebase after fixing conflicts"
echo
echo "🧭 Navigate"
echo "   gh stack view                        # show the current stack"
echo "   gh stack up / gh stack down          # move one layer up/down"
echo "   gh stack top / gh stack bottom       # jump to top/bottom of the stack"
echo "   gh stack switch                      # interactive branch picker"
echo "   gh stack checkout 7                  # check out stack #7 (or a PR #/URL)"
echo
echo "🛠️  Manage"
echo "   gh stack modify                      # reorder/drop/fold branches (TUI)"
echo "   gh stack merge                       # merge the stack's PRs (interactive)"
echo "   gh stack merge --yes --squash        # merge whole stack, squashing, no prompt"
echo "   gh stack unstack                     # remove current stack (local + GitHub)"
echo "   gh stack alias                       # add short 'gs' alias (gs push, gs view...)"
echo
echo "   Full reference: gh stack --help  /  gh stack <command> --help"
echo "════════════════════════════════════════════════════════"

# === 7. Test basic functionality ===
echo
echo "🧪 Testing basic functionality..."
if gh --version > /dev/null 2>&1
    echo "✅ Basic functionality test passed"

    # Test if authenticated
    if gh auth status > /dev/null 2>&1
        set github_user (gh api user --jq .login 2>/dev/null)
        if test -n "$github_user"
            echo "✅ Already authenticated as: $github_user"
        else
            echo "🔓 Not authenticated. Run 'gh auth login' to get started."
        end
    else
        echo "🔓 Not authenticated. Run 'gh auth login' to get started."
    end
else
    echo "⚠️  Basic functionality test failed"
end

echo
echo "🎉 GitHub CLI installation complete!"
echo
echo "💡 Next steps:"
echo "   1. Run 'gh auth login' to authenticate with GitHub"
echo "   2. Run 'gh help' to explore all available commands"
echo "   3. Check out https://cli.github.com/manual/ for detailed documentation"
