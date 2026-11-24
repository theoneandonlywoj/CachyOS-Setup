#!/bin/bash
cd "$(dirname "$0")" || exit 1
# Local testing script for CachyOS Setup without Docker
# This script validates Fish syntax and checks script structure

echo "🧪 Local Testing for CachyOS Setup Scripts"
echo "=========================================="
echo

# Check if Fish is installed
if ! command -v fish &> /dev/null; then
    echo "❌ Fish shell is not installed"
    echo "💡 Install Fish: sudo pacman -S fish"
    exit 1
fi

echo "✅ Fish shell found: $(fish --version)"
echo

# Counter for issues
failed_count=0
total_count=0

# Must equal the number of `legacy` rows in the README catalog; it may only go down.
LEGACY_MAX=77

# README command catalog (Steps 3-6 read each script's rerun tag from it)
catalog=$(sed -n '/^<!-- root-command-catalog -->$/,/^<!-- \/root-command-catalog -->$/p' README.md)
tag_of() { grep -F "| \`./$1\` |" <<<"$catalog" | awk -F'|' '{gsub(/ /, "", $4); print $4}'; }

# Test 1: Check if all .fish scripts have shebang
echo "📋 Step 1: Checking shebang lines..."
echo "-----------------------------------"
for script in *.fish; do
    if [ -f "$script" ]; then
        total_count=$((total_count + 1))
        if head -n 1 "$script" | grep -q '#!/usr/bin/env fish'; then
            echo "✅ $script"
        else
            echo "❌ $script - Missing shebang line"
            failed_count=$((failed_count + 1))
        fi
    fi
done
echo

# Test 2: Check Fish syntax
echo "📋 Step 2: Validating Fish syntax..."
echo "-----------------------------------"
for script in *.fish; do
    if [ -f "$script" ]; then
        echo -n "Checking $script... "
        if fish -n "$script" 2>/dev/null; then
            echo "✅"
        else
            echo "❌"
            fish -n "$script" 2>&1 || true
            failed_count=$((failed_count + 1))
        fi
    fi
done
echo

# Test 3: Check executability
echo "📋 Step 3: Checking file permissions..."
echo "-----------------------------------"
for script in *.fish; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "✅ $script is executable"
        elif [ "$(tag_of "$script")" != "legacy" ]; then
            echo "❌ $script is not executable"
            failed_count=$((failed_count + 1))
        else
            echo "⚠️  $script is not executable"
            chmod +x "$script"
            echo "   → Made executable"
        fi
    fi
done
echo

# Test 4: Check for required structure
echo "📋 Step 4: Checking script structure..."
echo "-----------------------------------"
for script in *.fish; do
    if [ -f "$script" ]; then
        has_purpose_or_desc=false
        has_author=false
        has_echo=false
        
        # Check for Purpose or Description
        if grep -q "Purpose:" "$script" 2>/dev/null || grep -q "Description:" "$script" 2>/dev/null; then
            has_purpose_or_desc=true
        fi
        
        # Check for Author
        if grep -q "Author:" "$script" 2>/dev/null; then
            has_author=true
        fi
        
        # Check for echo (indicates script does something)
        if grep -q "echo" "$script" 2>/dev/null; then
            has_echo=true
        fi
        
        if [ "$has_purpose_or_desc" = true ] && [ "$has_author" = true ] && [ "$has_echo" = true ]; then
            echo "✅ $script has proper structure"
        elif [ "$(tag_of "$script")" != "legacy" ]; then
            echo "❌ $script - Missing Purpose/Description, Author or echo"
            failed_count=$((failed_count + 1))
        else
            echo "⚠️  $script - Missing some structure elements"
        fi
    fi
done
echo

# Test 5: README command catalog lists every root script exactly once (and nothing else)
echo "📋 Step 5: Checking README command catalog..."
echo "-----------------------------------"
open_n=$(grep -c '^<!-- root-command-catalog -->$' README.md)
close_n=$(grep -c '^<!-- /root-command-catalog -->$' README.md)
if [ "$open_n" -ne 1 ] || [ "$close_n" -ne 1 ]; then
    echo "❌ README.md needs exactly one opening and one closing root-command-catalog marker (found $open_n/$close_n)"
    failed_count=$((failed_count + 1))
fi
legacy_count=0
for script in *.fish; do
    rows=$(grep -cF "| \`./$script\` |" <<<"$catalog")
    rerun=$(tag_of "$script")
    if [ "$rows" -gt 1 ]; then echo "❌ $script - listed $rows times"; failed_count=$((failed_count + 1)); continue; fi
    case "$rerun" in
        legacy) legacy_count=$((legacy_count + 1)); echo "✅ $script (legacy)" ;;
        skip|update|guide|setup) echo "✅ $script ($rerun)" ;;
        "") echo "❌ $script - missing from README catalog"; failed_count=$((failed_count + 1)) ;;
        *)  echo "❌ $script - unknown rerun tag '$rerun'"; failed_count=$((failed_count + 1)) ;;
    esac
done
if [ "$legacy_count" -ne "$LEGACY_MAX" ]; then
    echo "❌ $legacy_count legacy rows but LEGACY_MAX=$LEGACY_MAX: set LEGACY_MAX to the real count (it may only go down)"
    failed_count=$((failed_count + 1))
fi
for listed in $(grep -oE '^[|] `\./[A-Za-z0-9_.-]+\.fish`' <<<"$catalog" | sed -E 's/^[|] `\.\/(.*)`$/\1/'); do
    [ -f "$listed" ] || { echo "❌ README catalog lists missing script $listed"; failed_count=$((failed_count + 1)); }
done
echo

# Test 6: migrated scripts never remove packages, partially upgrade, or reinstall without --needed
echo "📋 Step 6: Checking rerun safety..."
echo "-----------------------------------"
PM='(pacman|paru|yay|\$\{?[a-z_]*helper(\[[0-9]+\])?\}?)"?([[:space:]]+--[a-z-]+)*[[:space:]]+'
for script in *.fish; do
    rerun=$(tag_of "$script")
    if [ -z "$rerun" ] || [ "$rerun" = "legacy" ]; then continue; fi
    # the escape is honoured only on printed hint text (a single echo/printf statement)
    body=$(grep -nvE '^[[:space:]]*(echo|printf)[[:space:]]+"[^";|&(\]*"[[:space:]]+# rerun-gate: allow [^ ]' "$script")
    hits=$(grep -iE "${PM}(-R[a-z]*|--remove|-Sy{1,2}([[:space:]]|$|;|\")|--refresh)" <<<"$body")
    noneeded=$(grep -iE "${PM}-S([[:space:]]|$)" <<<"$body" | awk '{ s = $0; sub(/^[0-9]+:/, "", s); if (s ~ /^[[:space:]]*#/) next; sub(/[[:space:];&|]#.*/, "", s); if (s !~ /--needed/) print }')
    if [ -n "$hits$noneeded" ]; then
        echo "❌ $script - forbidden on rerun:"; printf '%s\n' "$hits" "$noneeded" | sed "/^$/d; s/^/   $script:/"
        failed_count=$((failed_count + 1))
    else
        echo "✅ $script"
    fi
done
echo

# Summary
echo "=========================================="
echo "📊 Testing Summary"
echo "=========================================="
passed=$((total_count - failed_count))
echo "Total scripts: $total_count"
echo "Passed: $passed"
echo "Failed: $failed_count"

if [ $failed_count -eq 0 ]; then
    echo
    echo "🎉 All tests passed!"
    echo "✅ You can safely push to GitHub"
    exit 0
else
    echo
    echo "⚠️  Some tests failed"
    echo "💡 Fix the issues above before pushing"
    exit 1
fi

