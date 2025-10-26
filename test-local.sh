#!/bin/bash
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
        else
            echo "⚠️  $script - Missing some structure elements"
        fi
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

