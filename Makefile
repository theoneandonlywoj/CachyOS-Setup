# === Makefile for Doom Emacs & Cursor config sync ===
# Moves existing configs to timestamped backups and installs new configs
# Supports restore from the most recent backup

.PHONY: all sync backup restore soft-test help \
        cursor-sync cursor-backup cursor-restore cursor-diff \
        doom-sync doom-backup doom-restore

# Generate timestamp in format YYYY_mm_dd_hh_MM
TIMESTAMP := $(shell date +"%Y_%m_%d_%H_%M")

# Doom Emacs paths
DOOM_BACKUP_DIR := $(HOME)/.doom.d_backup_$(TIMESTAMP)

# Cursor paths (Linux)
CURSOR_CONFIG_DIR := $(HOME)/.config/Cursor/User
CURSOR_BACKUP_DIR := $(HOME)/.config/Cursor/User_backup_$(TIMESTAMP)
CURSOR_REPO_DIR := ./~/.config/Cursor/User

# ============================================================
# DEFAULT TARGET
# ============================================================

all: doom-sync cursor-sync
	@echo "✅ All configurations synced!"

# ============================================================
# CURSOR IDE CONFIGURATION
# ============================================================

cursor-sync: cursor-backup
	@echo "📦 Copying Cursor configuration..."
	@mkdir -p "$(CURSOR_CONFIG_DIR)"
	@cp "$(CURSOR_REPO_DIR)/settings.json" "$(CURSOR_CONFIG_DIR)/settings.json"
	@cp "$(CURSOR_REPO_DIR)/keybindings.json" "$(CURSOR_CONFIG_DIR)/keybindings.json"
	@echo "✅ Cursor configuration synced to $(CURSOR_CONFIG_DIR)"
	@echo "💡 Restart Cursor to apply changes"

cursor-backup:
	@if [ -f "$(CURSOR_CONFIG_DIR)/settings.json" ] || [ -f "$(CURSOR_CONFIG_DIR)/keybindings.json" ]; then \
		echo "💾 Backing up existing Cursor config to $(CURSOR_BACKUP_DIR)..."; \
		mkdir -p "$(CURSOR_BACKUP_DIR)"; \
		if [ -f "$(CURSOR_CONFIG_DIR)/settings.json" ]; then \
			cp "$(CURSOR_CONFIG_DIR)/settings.json" "$(CURSOR_BACKUP_DIR)/settings.json"; \
		fi; \
		if [ -f "$(CURSOR_CONFIG_DIR)/keybindings.json" ]; then \
			cp "$(CURSOR_CONFIG_DIR)/keybindings.json" "$(CURSOR_BACKUP_DIR)/keybindings.json"; \
		fi; \
		echo "✅ Backup created at $(CURSOR_BACKUP_DIR)"; \
	else \
		echo "ℹ️ No existing Cursor config found — skipping backup."; \
	fi

cursor-restore:
	@echo "♻️  Restoring the most recent Cursor backup..."
	@latest_backup=$$(ls -d $(HOME)/.config/Cursor/User_backup_* 2>/dev/null | sort -r | head -n 1); \
	if [ -z "$$latest_backup" ]; then \
		echo "❌ No Cursor backups found. Cannot restore."; \
		exit 1; \
	fi; \
	echo "♻️  Restoring from $$latest_backup..."; \
	if [ -f "$$latest_backup/settings.json" ]; then \
		cp "$$latest_backup/settings.json" "$(CURSOR_CONFIG_DIR)/settings.json"; \
	fi; \
	if [ -f "$$latest_backup/keybindings.json" ]; then \
		cp "$$latest_backup/keybindings.json" "$(CURSOR_CONFIG_DIR)/keybindings.json"; \
	fi; \
	echo "✅ Cursor restore complete from $$latest_backup"; \
	echo "💡 Restart Cursor to apply changes"

cursor-diff:
	@echo "📊 Comparing Cursor configurations..."
	@echo "=== settings.json ==="
	@diff -u "$(CURSOR_CONFIG_DIR)/settings.json" "$(CURSOR_REPO_DIR)/settings.json" 2>/dev/null || echo "(files differ or missing)"
	@echo
	@echo "=== keybindings.json ==="
	@diff -u "$(CURSOR_CONFIG_DIR)/keybindings.json" "$(CURSOR_REPO_DIR)/keybindings.json" 2>/dev/null || echo "(files differ or missing)"

# ============================================================
# DOOM EMACS CONFIGURATION
# ============================================================

doom-sync: doom-backup
	@echo "📦 Copying new Doom Emacs configuration..."
	@cp -r ./.doom.d $(HOME)/.doom.d
	@doom sync
	@echo "✅ New configuration synced to $(HOME)/.doom.d"

doom-backup:
	@if [ -d "$(HOME)/.doom.d" ]; then \
		echo "💾 Backing up existing ~/.doom.d to $(DOOM_BACKUP_DIR)..."; \
		mv "$(HOME)/.doom.d" "$(DOOM_BACKUP_DIR)"; \
		echo "✅ Backup created at $(DOOM_BACKUP_DIR)"; \
	else \
		echo "ℹ️ No existing ~/.doom.d found — skipping backup."; \
	fi

doom-restore:
	@echo "♻️  Restoring the most recent Doom Emacs backup..."
	@latest_backup=$$(ls -d $(HOME)/.doom.d_backup_* 2>/dev/null | sort -r | head -n 1); \
	if [ -z "$$latest_backup" ]; then \
		echo "❌ No backups found. Cannot restore."; \
		exit 1; \
	fi; \
	if [ -d "$(HOME)/.doom.d" ]; then \
		echo "🗑  Removing current ~/.doom.d before restore..."; \
		rm -rf "$(HOME)/.doom.d"; \
	fi; \
	echo "♻️  Restoring from $$latest_backup..."; \
	mv "$$latest_backup" "$(HOME)/.doom.d"; \
	echo "✅ Restore complete from $$latest_backup"

# ============================================================
# CONVENIENCE ALIASES
# ============================================================

sync: doom-sync cursor-sync
	@echo "✅ All configurations synced!"

backup: doom-backup cursor-backup

restore: doom-restore cursor-restore

# ============================================================
# TESTING
# ============================================================

soft-test:
	@echo "🧪 Local Testing for CachyOS Setup Scripts"
	@echo "=========================================="
	@echo
	@if ! command -v fish >/dev/null 2>&1; then \
		echo "❌ Fish shell is not installed"; \
		echo "💡 Install Fish: sudo pacman -S fish"; \
		exit 1; \
	fi
	@echo "✅ Fish shell found: $$(fish --version)"
	@echo
	@failed_count=0; \
	total_count=0; \
	\
	# Test 1: Check if all .fish scripts have shebang \
	echo "📋 Step 1: Checking shebang lines..."; \
	echo "-----------------------------------"; \
	for script in *.fish; do \
		if [ -f "$$script" ]; then \
			total_count=$$((total_count + 1)); \
			if head -n 1 "$$script" | grep -q '#!/usr/bin/env fish'; then \
				echo "✅ $$script"; \
			else \
				echo "❌ $$script - Missing shebang line"; \
				failed_count=$$((failed_count + 1)); \
			fi; \
		fi; \
	done; \
	echo; \
	\
	# Test 2: Check Fish syntax \
	echo "📋 Step 2: Validating Fish syntax..."; \
	echo "-----------------------------------"; \
	for script in *.fish; do \
		if [ -f "$$script" ]; then \
			echo -n "Checking $$script... "; \
			if fish -n "$$script" 2>/dev/null; then \
				echo "✅"; \
			else \
				echo "❌"; \
				fish -n "$$script" 2>&1 || true; \
				failed_count=$$((failed_count + 1)); \
			fi; \
		fi; \
	done; \
	echo; \
	\
	# Test 3: Check executability \
	echo "📋 Step 3: Checking file permissions..."; \
	echo "-----------------------------------"; \
	for script in *.fish; do \
		if [ -f "$$script" ]; then \
			if [ -x "$$script" ]; then \
				echo "✅ $$script is executable"; \
			else \
				echo "⚠️  $$script is not executable"; \
				chmod +x "$$script"; \
				echo "   → Made executable"; \
			fi; \
		fi; \
	done; \
	echo; \
	\
	# Test 4: Check for required structure \
	echo "📋 Step 4: Checking script structure..."; \
	echo "-----------------------------------"; \
	for script in *.fish; do \
		if [ -f "$$script" ]; then \
			has_purpose_or_desc=false; \
			has_author=false; \
			has_echo=false; \
			if grep -q "Purpose:" "$$script" 2>/dev/null || grep -q "Description:" "$$script" 2>/dev/null; then \
				has_purpose_or_desc=true; \
			fi; \
			if grep -q "Author:" "$$script" 2>/dev/null; then \
				has_author=true; \
			fi; \
			if grep -q "echo" "$$script" 2>/dev/null; then \
				has_echo=true; \
			fi; \
			if [ "$$has_purpose_or_desc" = true ] && [ "$$has_author" = true ] && [ "$$has_echo" = true ]; then \
				echo "✅ $$script has proper structure"; \
			else \
				echo "⚠️  $$script - Missing some structure elements"; \
				if [ "$$has_purpose_or_desc" = false ]; then \
					echo "   → Missing Purpose/Description"; \
				fi; \
				if [ "$$has_author" = false ]; then \
					echo "   → Missing Author"; \
				fi; \
				if [ "$$has_echo" = false ]; then \
					echo "   → Missing echo statements"; \
				fi; \
			fi; \
		fi; \
	done; \
	echo; \
	\
	# Summary \
	echo "=========================================="; \
	echo "📊 Testing Summary"; \
	echo "=========================================="; \
	passed=$$((total_count - failed_count)); \
	echo "Total scripts: $$total_count"; \
	echo "Passed: $$passed"; \
	echo "Failed: $$failed_count"; \
	if [ $$failed_count -eq 0 ]; then \
		echo; \
		echo "🎉 All tests passed!"; \
		echo "✅ You can safely push to GitHub"; \
		exit 0; \
	else \
		echo; \
		echo "⚠️  Some tests failed"; \
		echo "💡 Fix the issues above before pushing"; \
		exit 1; \
	fi

# ============================================================
# HELP
# ============================================================

help:
	@echo "CachyOS Setup - Available Targets"
	@echo "=================================="
	@echo
	@echo "ALL:"
	@echo "  make all              Sync both Doom Emacs and Cursor configs"
	@echo
	@echo "CURSOR IDE:"
	@echo "  make cursor-sync      Backup and sync Cursor settings/keybindings"
	@echo "  make cursor-backup    Backup current Cursor config"
	@echo "  make cursor-restore   Restore most recent Cursor backup"
	@echo "  make cursor-diff      Show differences between repo and installed"
	@echo
	@echo "DOOM EMACS:"
	@echo "  make doom-sync        Backup and sync Doom Emacs config"
	@echo "  make doom-backup      Backup current ~/.doom.d"
	@echo "  make doom-restore     Restore most recent Doom backup"
	@echo
	@echo "TESTING:"
	@echo "  make soft-test        Validate Fish scripts (syntax, structure)"
	@echo
	@echo "SHORTCUTS:"
	@echo "  make sync             Sync both Doom Emacs and Cursor (alias for 'all')"
	@echo "  make backup           Backup both Doom Emacs and Cursor"
	@echo "  make restore          Restore both from most recent backups"
	@echo
	@echo "HELP:"
	@echo "  make help             Show this help message"
