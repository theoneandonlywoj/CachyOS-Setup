# === Makefile for Doom Emacs config sync ===
# Moves existing ~/.doom.d to a timestamped backup and installs new config
# Supports restore from the most recent backup

.PHONY: sync backup restore

# Generate timestamp in format YYYY_mm_dd_hh_MM
TIMESTAMP := $(shell date +"%Y_%m_%d_%H_%M")
BACKUP_DIR := $(HOME)/.doom.d_backup_$(TIMESTAMP)

sync: backup
	@echo "📦 Copying new Doom Emacs configuration..."
	@cp -r ./.doom.d $(HOME)/.doom.d
	@echo "✅ New configuration synced to $(HOME)/.doom.d"

backup:
	@if [ -d "$(HOME)/.doom.d" ]; then \
		echo "💾 Backing up existing ~/.doom.d to $(BACKUP_DIR)..."; \
		mv "$(HOME)/.doom.d" "$(BACKUP_DIR)"; \
		echo "✅ Backup created at $(BACKUP_DIR)"; \
	else \
		echo "ℹ️ No existing ~/.doom.d found — skipping backup."; \
	fi

restore:
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
