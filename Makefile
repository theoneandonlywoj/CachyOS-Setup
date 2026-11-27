# === Makefile for Doom Emacs, Tmux & opencode config sync ===
# Moves existing configs to timestamped backups and installs new configs
# Supports restore from the most recent backup

.PHONY: all sync backup restore soft-test help \
        doom-sync doom-backup doom-restore \
        tmux-sync tmux-backup tmux-restore tmux-diff \
        openclaw-sync openclaw-backup openclaw-restore \
        opencode-backup opencode-sync opencode-restore opencode-diff \
        add_pocock_skills delete_pocock_skills \
        purge-claude-skills purge-opencode-skills \
        check-skills-mirror \
        mermaid-install mermaid-check \
        herdr-global-set herdr-global-unset herdr-global-backup herdr-global-restore herdr-global-diff herdr-remove-backups

# Generate timestamp in format YYYY_mm_dd_hh_MM
TIMESTAMP := $(shell date +"%Y_%m_%d_%H_%M")

# Doom Emacs paths
DOOM_BACKUP_DIR := $(HOME)/.doom.d_backup_$(TIMESTAMP)

# Tmux paths
TMUX_CONFIG := $(HOME)/.tmux.conf
TMUX_BACKUP := $(HOME)/.tmux.conf_backup_$(TIMESTAMP)
TPM_DIR := $(HOME)/.tmux/plugins/tpm

# OpenClaw paths
OPENCLAW_DIR := $(HOME)/.openclaw
OPENCLAW_REPO_DIR := ./.openclaw
OPENCLAW_BACKUP_DIR := $(HOME)/.openclaw_backup_$(TIMESTAMP)

# opencode paths
OPENCODE_DIR := $(HOME)/.config/opencode
OPENCODE_REPO_DIR := ./.opencode
OPENCODE_BACKUP_DIR := $(HOME)/.config/opencode_backup_$(TIMESTAMP)

# Global agent skill paths
CLAUDE_GLOBAL_SKILLS_DIR := $(HOME)/.claude/skills
OPENCODE_GLOBAL_SKILLS_DIR := $(HOME)/.config/opencode/skills
POCOCK_SKILLS_REPO := https://github.com/mattpocock/skills.git
POCOCK_SKILLS_SOURCE_DIR := $(HOME)/.local/share/cachyos-setup/mattpocock-skills
POCOCK_SKILLS_REF ?= main
POCOCK_SKILLS_BUCKETS := engineering productivity

# Herdr paths
HERDR_REPO_DIR := ./.config/herdr
HERDR_HOME_DIR := $(HOME)/.config/herdr
HERDR_REPO_CONFIG := $(HERDR_REPO_DIR)/config.toml
HERDR_HOME_CONFIG := $(HERDR_HOME_DIR)/config.toml

# ============================================================
# DEFAULT TARGET
# ============================================================

all: doom-sync opencode-sync herdr-global-set
	@echo "✅ All configurations synced!"

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
# TMUX CONFIGURATION
# ============================================================

tmux-sync: tmux-backup
	@echo "📦 Copying tmux configuration..."
	@cp ./.tmux.conf "$(TMUX_CONFIG)"
	@echo "✅ Tmux configuration synced to $(TMUX_CONFIG)"
	@# Install TPM (Tmux Plugin Manager) if not present
	@if [ ! -d "$(TPM_DIR)" ]; then \
		echo "📦 Installing Tmux Plugin Manager (TPM)..."; \
		git clone https://github.com/tmux-plugins/tpm "$(TPM_DIR)"; \
		echo "✅ TPM installed to $(TPM_DIR)"; \
	else \
		echo "ℹ️  TPM already installed at $(TPM_DIR)"; \
	fi
	@echo "💡 Reload tmux config: tmux source-file ~/.tmux.conf"
	@echo "💡 Install plugins: prefix + I (Ctrl+a then Shift+i)"
	@# Auto-reload if tmux is running
	@if tmux list-sessions >/dev/null 2>&1; then \
		echo "🔄 Reloading tmux configuration..."; \
		tmux source-file "$(TMUX_CONFIG)" 2>/dev/null && echo "✅ Config reloaded!" || echo "⚠️  Reload manually with: tmux source-file ~/.tmux.conf"; \
	fi

tmux-backup:
	@if [ -f "$(TMUX_CONFIG)" ]; then \
		echo "💾 Backing up existing ~/.tmux.conf to $(TMUX_BACKUP)..."; \
		cp "$(TMUX_CONFIG)" "$(TMUX_BACKUP)"; \
		echo "✅ Backup created at $(TMUX_BACKUP)"; \
	else \
		echo "ℹ️  No existing ~/.tmux.conf found — skipping backup."; \
	fi

tmux-restore:
	@echo "♻️  Restoring the most recent tmux backup..."
	@latest_backup=$$(ls -t $(HOME)/.tmux.conf_backup_* 2>/dev/null | head -n 1); \
	if [ -z "$$latest_backup" ]; then \
		echo "❌ No tmux backups found. Cannot restore."; \
		exit 1; \
	fi; \
	echo "♻️  Restoring from $$latest_backup..."; \
	cp "$$latest_backup" "$(TMUX_CONFIG)"; \
	echo "✅ Tmux restore complete from $$latest_backup"; \
	echo "💡 Reload config: tmux source-file ~/.tmux.conf"

tmux-diff:
	@echo "📊 Comparing tmux configurations..."
	@diff -u "$(TMUX_CONFIG)" "./.tmux.conf" 2>/dev/null || echo "(files differ or missing)"

# ============================================================
# OPENCLAW CONFIGURATION
# ============================================================

openclaw-backup:
	@echo "📦 Saving OpenClaw config to repo..."
	@if [ ! -d "$(OPENCLAW_DIR)" ]; then \
		echo "❌ No ~/.openclaw/ found — nothing to save."; \
		exit 1; \
	fi
	@mkdir -p "$(OPENCLAW_REPO_DIR)"
	@# Main config
	@cp "$(OPENCLAW_DIR)/openclaw.json" "$(OPENCLAW_REPO_DIR)/openclaw.json"
	@# Auth profiles
	@mkdir -p "$(OPENCLAW_REPO_DIR)/agents/main/agent"
	@cp "$(OPENCLAW_DIR)/agents/main/agent/auth-profiles.json" \
		"$(OPENCLAW_REPO_DIR)/agents/main/agent/auth-profiles.json" 2>/dev/null || true
	@# Cron jobs
	@mkdir -p "$(OPENCLAW_REPO_DIR)/cron"
	@cp "$(OPENCLAW_DIR)/cron/jobs.json" "$(OPENCLAW_REPO_DIR)/cron/jobs.json" 2>/dev/null || true
	@# Paired devices
	@mkdir -p "$(OPENCLAW_REPO_DIR)/devices"
	@cp "$(OPENCLAW_DIR)/devices/paired.json" "$(OPENCLAW_REPO_DIR)/devices/paired.json" 2>/dev/null || true
	@# Identity (device keypair + auth)
	@mkdir -p "$(OPENCLAW_REPO_DIR)/identity"
	@cp "$(OPENCLAW_DIR)/identity/"*.json "$(OPENCLAW_REPO_DIR)/identity/" 2>/dev/null || true
	@# Agent memory database
	@mkdir -p "$(OPENCLAW_REPO_DIR)/memory"
	@cp "$(OPENCLAW_DIR)/memory/main.sqlite" "$(OPENCLAW_REPO_DIR)/memory/main.sqlite" 2>/dev/null || true
	@# Workspace config (*.md files + memory/*.md, skip .git/ and .openclaw/)
	@mkdir -p "$(OPENCLAW_REPO_DIR)/workspace/memory"
	@cp "$(OPENCLAW_DIR)/workspace/"*.md "$(OPENCLAW_REPO_DIR)/workspace/" 2>/dev/null || true
	@cp "$(OPENCLAW_DIR)/workspace/memory/"*.md "$(OPENCLAW_REPO_DIR)/workspace/memory/" 2>/dev/null || true
	@echo "✅ OpenClaw config saved to $(OPENCLAW_REPO_DIR)"

openclaw-sync:
	@echo "📦 Deploying OpenClaw config from repo..."
	@if [ ! -d "$(OPENCLAW_REPO_DIR)" ]; then \
		echo "❌ No ./.openclaw/ in repo — run 'make openclaw-backup' first."; \
		exit 1; \
	fi
	@if [ -d "$(OPENCLAW_DIR)" ]; then \
		echo "💾 Creating backup at $(OPENCLAW_BACKUP_DIR)..."; \
		cp -r "$(OPENCLAW_DIR)" "$(OPENCLAW_BACKUP_DIR)"; \
		echo "✅ Backup created"; \
	fi
	@mkdir -p "$(OPENCLAW_DIR)"
	@cp "$(OPENCLAW_REPO_DIR)/openclaw.json" "$(OPENCLAW_DIR)/openclaw.json"
	@mkdir -p "$(OPENCLAW_DIR)/agents/main/agent"
	@cp "$(OPENCLAW_REPO_DIR)/agents/main/agent/auth-profiles.json" \
		"$(OPENCLAW_DIR)/agents/main/agent/auth-profiles.json" 2>/dev/null || true
	@mkdir -p "$(OPENCLAW_DIR)/cron"
	@cp "$(OPENCLAW_REPO_DIR)/cron/jobs.json" "$(OPENCLAW_DIR)/cron/jobs.json" 2>/dev/null || true
	@mkdir -p "$(OPENCLAW_DIR)/devices"
	@cp "$(OPENCLAW_REPO_DIR)/devices/paired.json" "$(OPENCLAW_DIR)/devices/paired.json" 2>/dev/null || true
	@mkdir -p "$(OPENCLAW_DIR)/identity"
	@cp "$(OPENCLAW_REPO_DIR)/identity/"*.json "$(OPENCLAW_DIR)/identity/" 2>/dev/null || true
	@mkdir -p "$(OPENCLAW_DIR)/memory"
	@cp "$(OPENCLAW_REPO_DIR)/memory/main.sqlite" "$(OPENCLAW_DIR)/memory/main.sqlite" 2>/dev/null || true
	@mkdir -p "$(OPENCLAW_DIR)/workspace/memory"
	@cp "$(OPENCLAW_REPO_DIR)/workspace/"*.md "$(OPENCLAW_DIR)/workspace/" 2>/dev/null || true
	@cp "$(OPENCLAW_REPO_DIR)/workspace/memory/"*.md "$(OPENCLAW_DIR)/workspace/memory/" 2>/dev/null || true
	@echo "✅ OpenClaw config deployed to $(OPENCLAW_DIR)"

openclaw-restore:
	@echo "♻️  Restoring the most recent OpenClaw backup..."
	@latest_backup=$$(ls -d $(HOME)/.openclaw_backup_* 2>/dev/null | sort -r | head -n 1); \
	if [ -z "$$latest_backup" ]; then \
		echo "❌ No OpenClaw backups found. Cannot restore."; \
		exit 1; \
	fi; \
	if [ -d "$(OPENCLAW_DIR)" ]; then \
		rm -rf "$(OPENCLAW_DIR)"; \
	fi; \
	echo "♻️  Restoring from $$latest_backup..."; \
	mv "$$latest_backup" "$(OPENCLAW_DIR)"; \
	echo "✅ OpenClaw restore complete from $$latest_backup"

# ============================================================
# OPENCODE CONFIGURATION
# ============================================================

opencode-backup:
	@if [ -d "$(OPENCODE_DIR)" ]; then \
		echo "💾 Backing up existing $(OPENCODE_DIR) to $(OPENCODE_BACKUP_DIR)..."; \
		mv "$(OPENCODE_DIR)" "$(OPENCODE_BACKUP_DIR)"; \
		echo "✅ Backup created at $(OPENCODE_BACKUP_DIR)"; \
	else \
		echo "ℹ️ No existing $(OPENCODE_DIR) found — skipping backup."; \
	fi

opencode-sync: opencode-backup
	@echo "📦 Copying opencode configuration..."
	@cp -r "$(OPENCODE_REPO_DIR)" "$(OPENCODE_DIR)"
	@echo "✅ opencode configuration synced to $(OPENCODE_DIR)"
	@echo "💡 Restart opencode to apply changes"

opencode-restore:
	@echo "♻️  Restoring the most recent opencode backup..."
	@latest_backup=$$(ls -d $(HOME)/.config/opencode_backup_* 2>/dev/null | sort -r | head -n 1); \
	if [ -z "$$latest_backup" ]; then \
		echo "❌ No opencode backups found. Cannot restore."; \
		exit 1; \
	fi; \
	if [ -d "$(OPENCODE_DIR)" ]; then \
		echo "🗑  Removing current $(OPENCODE_DIR) before restore..."; \
		rm -rf "$(OPENCODE_DIR)"; \
	fi; \
	echo "♻️  Restoring from $$latest_backup..."; \
	mv "$$latest_backup" "$(OPENCODE_DIR)"; \
	echo "✅ opencode restore complete from $$latest_backup"

opencode-diff:
	@echo "📊 Comparing opencode configurations..."
	@echo "=== opencode.json ==="
	@diff -u "$(OPENCODE_DIR)/opencode.json" "$(OPENCODE_REPO_DIR)/opencode.json" 2>/dev/null || echo "(files differ or missing)"
	@echo
	@echo "=== Differing files summary ==="
	@diff -rq \
		--exclude=node_modules \
		--exclude=package.json \
		--exclude=package-lock.json \
		--exclude=bun.lock \
		--exclude=.gitignore \
		"$(OPENCODE_DIR)" "$(OPENCODE_REPO_DIR)" 2>/dev/null || echo "(directories differ or missing)"

# ============================================================
# GLOBAL AGENT SKILLS
# ============================================================

add_pocock_skills:
	@echo "📦 Installing Matt Pocock engineering and productivity skills..."
	@if [ -d "$(POCOCK_SKILLS_SOURCE_DIR)/.git" ]; then \
		echo "🔄 Updating $(POCOCK_SKILLS_SOURCE_DIR)..."; \
		git -C "$(POCOCK_SKILLS_SOURCE_DIR)" pull --ff-only origin "$(POCOCK_SKILLS_REF)"; \
	elif [ -e "$(POCOCK_SKILLS_SOURCE_DIR)" ]; then \
		echo "❌ $(POCOCK_SKILLS_SOURCE_DIR) exists but is not a Git checkout."; \
		exit 1; \
	else \
		mkdir -p "$$(dirname "$(POCOCK_SKILLS_SOURCE_DIR)")"; \
		git clone --depth 1 --branch "$(POCOCK_SKILLS_REF)" "$(POCOCK_SKILLS_REPO)" "$(POCOCK_SKILLS_SOURCE_DIR)"; \
	fi
	@for destination in "$(CLAUDE_GLOBAL_SKILLS_DIR)" "$(OPENCODE_GLOBAL_SKILLS_DIR)"; do \
		if [ -L "$$destination" ]; then \
			echo "❌ Refusing to use symlinked skills directory: $$destination"; \
			exit 1; \
		fi; \
		mkdir -p "$$destination"; \
		for bucket in $(POCOCK_SKILLS_BUCKETS); do \
			if [ ! -d "$(POCOCK_SKILLS_SOURCE_DIR)/skills/$$bucket" ]; then \
				echo "❌ Missing upstream skill bucket: $$bucket"; \
				exit 1; \
			fi; \
			for skill_dir in "$(POCOCK_SKILLS_SOURCE_DIR)/skills/$$bucket"/*; do \
				[ -d "$$skill_dir" ] || continue; \
				[ -f "$$skill_dir/SKILL.md" ] || continue; \
				name="$$(basename "$$skill_dir")"; \
				target="$$destination/$$name"; \
				if [ -L "$$target" ]; then \
					link_target="$$(readlink "$$target")"; \
					case "$$link_target" in \
						"$(POCOCK_SKILLS_SOURCE_DIR)"/*) rm -f "$$target" ;; \
						*) echo "❌ Refusing to replace unrelated skill: $$target"; exit 1 ;; \
					esac; \
				elif [ -e "$$target" ]; then \
					echo "❌ Refusing to replace existing skill: $$target"; \
					exit 1; \
				fi; \
				ln -s "$$skill_dir" "$$target"; \
				echo "✅ Linked $$name into $$destination"; \
			done; \
		done; \
	done
	@echo "✅ Matt Pocock skills installed globally"

delete_pocock_skills:
	@removed=0; \
	for destination in "$(CLAUDE_GLOBAL_SKILLS_DIR)" "$(OPENCODE_GLOBAL_SKILLS_DIR)"; do \
		if [ ! -d "$$destination" ]; then \
			echo "ℹ️  No skills directory at $$destination — skipping."; \
			continue; \
		fi; \
		if [ -L "$$destination" ]; then \
			echo "❌ Refusing to clean symlinked skills directory: $$destination"; \
			exit 1; \
		fi; \
		for skill in "$$destination"/*; do \
			[ -L "$$skill" ] || continue; \
			link_target="$$(readlink "$$skill")"; \
			case "$$link_target" in \
				"$(POCOCK_SKILLS_SOURCE_DIR)"/*) rm -f "$$skill"; removed=$$((removed + 1)); echo "🗑  Removed $$skill" ;; \
			esac; \
		done; \
	done; \
	if [ -d "$(POCOCK_SKILLS_SOURCE_DIR)" ]; then \
		rm -rf "$(POCOCK_SKILLS_SOURCE_DIR)"; \
		echo "🗑  Removed $(POCOCK_SKILLS_SOURCE_DIR)"; \
	fi; \
	echo "✅ Removed $$removed Matt Pocock skill links"

purge-claude-skills:
	@if [ ! -d "$(CLAUDE_GLOBAL_SKILLS_DIR)" ]; then \
		echo "❌ Claude skills directory is missing: $(CLAUDE_GLOBAL_SKILLS_DIR)"; \
		exit 1; \
	fi
	@if [ -L "$(CLAUDE_GLOBAL_SKILLS_DIR)" ]; then \
		echo "❌ Refusing to purge symlinked Claude skills directory: $(CLAUDE_GLOBAL_SKILLS_DIR)"; \
		exit 1; \
	fi
	@echo "🗑  Purging skills inside $(CLAUDE_GLOBAL_SKILLS_DIR)..."
	@find "$(CLAUDE_GLOBAL_SKILLS_DIR)" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
	@echo "✅ Claude skills purged; ~/.claude configuration was preserved"

purge-opencode-skills:
	@if [ ! -d "$(OPENCODE_GLOBAL_SKILLS_DIR)" ]; then \
		echo "❌ OpenCode skills directory is missing: $(OPENCODE_GLOBAL_SKILLS_DIR)"; \
		exit 1; \
	fi
	@if [ -L "$(OPENCODE_GLOBAL_SKILLS_DIR)" ]; then \
		echo "❌ Refusing to purge symlinked OpenCode skills directory: $(OPENCODE_GLOBAL_SKILLS_DIR)"; \
		exit 1; \
	fi
	@echo "🗑  Purging skills inside $(OPENCODE_GLOBAL_SKILLS_DIR)..."
	@find "$(OPENCODE_GLOBAL_SKILLS_DIR)" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
	@echo "✅ OpenCode skills purged; ~/.config/opencode configuration was preserved"

# ============================================================
# CROSS-HARNESS MIRROR CHECK
# ============================================================

# Verifies that .opencode/ and .claude/ skills and commands stay in sync,
# ignoring the only legitimate differences: the harness path token
# (.opencode/ vs .claude/) and OpenCode-only command frontmatter
# (agent: / subtask:). Fails non-zero on any other drift.
check-skills-mirror:
	@echo "🔍 Checking cross-harness skill/command mirror..."
	@status=0; \
	for dir in skills commands; do \
	  for f in $$(cd .opencode/$$dir && find . -type f | sed 's#^\./##'); do \
	    a=".opencode/$$dir/$$f"; b=".claude/$$dir/$$f"; \
	    if [ ! -f "$$b" ]; then echo "  ❌ MISSING in .claude/$$dir: $$f"; status=1; continue; fi; \
	    da=$$(sed -e '/^agent:/d' -e '/^subtask:/d' -e 's#\.opencode#HARNESS#g' -e 's#\.claude#HARNESS#g' "$$a"); \
	    db=$$(sed -e '/^agent:/d' -e '/^subtask:/d' -e 's#\.opencode#HARNESS#g' -e 's#\.claude#HARNESS#g' "$$b"); \
	    if [ "$$da" != "$$db" ]; then \
	      echo "  ❌ DRIFT in $$dir/$$f"; \
	      tmp_a=$$(mktemp); tmp_b=$$(mktemp); \
	      printf '%s\n' "$$da" > "$$tmp_a"; printf '%s\n' "$$db" > "$$tmp_b"; \
	      diff -u "$$tmp_a" "$$tmp_b" | sed 's/^/    /'; \
	      rm -f "$$tmp_a" "$$tmp_b"; \
	      status=1; \
	    fi; \
	  done; \
	  for f in $$(cd .claude/$$dir && find . -type f | sed 's#^\./##'); do \
	    [ -f ".opencode/$$dir/$$f" ] || { echo "  ❌ MISSING in .opencode/$$dir: $$f"; status=1; }; \
	  done; \
	done; \
	if [ $$status -eq 0 ]; then echo "  ✅ Skill/command mirror is in sync."; else echo "  ❌ Mirror drift detected; see above."; exit 1; fi

# ============================================================
# MERMAID VALIDATION
# ============================================================

mermaid-install:
	@if ! command -v mise >/dev/null 2>&1; then \
		echo "❌ mise is required to install the pinned Mermaid CLI."; \
		exit 1; \
	fi
	@echo "📦 Installing tools from .tool-versions..."
	@PUPPETEER_SKIP_DOWNLOAD=1 mise install
	@echo "✅ Mermaid CLI 11.15.0 is installed"

mermaid-check: mermaid-install
	@echo "🔍 Validating Mermaid diagrams with Mermaid CLI 11.15.0..."
	@set -e; \
	browser=$$(command -v chromium || command -v chromium-browser || command -v google-chrome || true); \
	if [ -z "$$browser" ]; then \
		echo "❌ Chromium or Google Chrome is required to render Mermaid diagrams."; \
		exit 1; \
	fi; \
	tmp_dir=$$(mktemp -d); \
	trap 'rm -rf "$$tmp_dir"' EXIT; \
	mise exec -- node -e 'const fs=require("fs"); const text=fs.readFileSync("docs/POCOCK_SKILLS_WORKFLOW.md", "utf8"); const blocks=[...text.matchAll(/```mermaid\n([\s\S]*?)```/g)]; if (!blocks.length) { console.error("No Mermaid diagrams found."); process.exit(1); } fs.mkdirSync(process.argv[1], { recursive: true }); blocks.forEach((match, index) => fs.writeFileSync(`$${process.argv[1]}/diagram-$${index + 1}.mmd`, match[1])); console.log(`Extracted $${blocks.length} Mermaid diagrams.`);' "$$tmp_dir"; \
	for diagram in "$$tmp_dir"/*.mmd; do \
		PUPPETEER_EXECUTABLE_PATH="$$browser" mise exec -- mmdc -i "$$diagram" -o "$$diagram.svg" --quiet; \
	done; \
	echo "✅ All Mermaid diagrams passed Mermaid CLI 11.15.0"

# ============================================================
# HERDR CONFIGURATION
# ============================================================

herdr-global-set: herdr-global-backup
	@echo "📦 Copying Herdr configuration and Fish helper scripts..."
	@mkdir -p "$(HERDR_HOME_DIR)" && cp "$(HERDR_REPO_CONFIG)" "$(HERDR_HOME_CONFIG)" || exit 1
	@if [ -d "$(HERDR_REPO_DIR)/scripts" ]; then \
		mkdir -p "$(HERDR_HOME_DIR)/scripts" && \
		cp "$(HERDR_REPO_DIR)"/scripts/* "$(HERDR_HOME_DIR)/scripts/" && \
		chmod +x "$(HERDR_HOME_DIR)"/scripts/* || exit 1; \
	fi
	@if command -v herdr >/dev/null 2>&1; then \
		echo "🔄 Reloading Herdr config..."; \
		herdr server reload-config >/dev/null 2>&1 || true; \
	else \
		echo "⚠️  herdr command not found — config copied, reload skipped"; \
	fi
	@echo "✅ Herdr configuration synced to $(HERDR_HOME_DIR)"

herdr-global-unset:
	@$(MAKE) --no-print-directory herdr-global-backup
	@if [ -f "$(HERDR_HOME_CONFIG)" ]; then \
		rm "$(HERDR_HOME_CONFIG)" || exit 1; \
		echo "✅ Removed $(HERDR_HOME_CONFIG)"; \
	else \
		echo "ℹ️  No $(HERDR_HOME_CONFIG) to remove."; \
	fi
	@rmdir "$(HERDR_HOME_DIR)" 2>/dev/null || true
	@if command -v herdr >/dev/null 2>&1; then \
		echo "🔄 Reloading Herdr config..."; \
		herdr server reload-config >/dev/null 2>&1 || true; \
	fi

herdr-global-backup:
	@if [ -f "$(HERDR_HOME_CONFIG)" ]; then \
		d=$$(mktemp -d "./.herdr-$$(date +%Y_%m_%d_%H_%M_%S)-XXXX") && cp "$(HERDR_HOME_CONFIG)" "$$d/config.toml" \
			|| { echo "❌ Herdr backup failed; nothing changed."; exit 1; }; \
		echo "✅ Backup created at $$d"; \
	else echo "ℹ️  No existing $(HERDR_HOME_CONFIG) found — skipping backup."; fi

herdr-global-restore:
	@src=""; for d in $$(ls -td .herdr-*/ 2>/dev/null); do \
		if [ -f "$${d}config.toml" ]; then src="$${d}config.toml"; break; fi; done; \
	if [ -z "$$src" ]; then src=$$(ls -t "$(HERDR_HOME_DIR)"/config.toml.backup_* 2>/dev/null | head -n 1); fi; \
	if [ -z "$$src" ]; then echo "❌ No backups found. Cannot restore."; exit 1; fi; \
	mkdir -p "$(HERDR_HOME_DIR)" && cp "$$src" "$(HERDR_HOME_CONFIG)" || { echo "❌ Restore failed from $$src"; exit 1; }; \
	echo "✅ Restore complete from $$src"; \
	if command -v herdr >/dev/null 2>&1; then herdr server reload-config >/dev/null 2>&1 || true; fi

herdr-global-diff:
	@echo "📊 Comparing Herdr configurations..."
	@echo "=== config.toml ==="
	@diff -u "$(HERDR_HOME_CONFIG)" "$(HERDR_REPO_CONFIG)" 2>/dev/null || echo "(files differ or missing)"
	@echo
	@echo "=== helper scripts ==="
	@if [ -d "$(HERDR_HOME_DIR)/scripts" ] && [ -d "$(HERDR_REPO_DIR)/scripts" ]; then \
		diff -ru "$(HERDR_HOME_DIR)/scripts" "$(HERDR_REPO_DIR)/scripts" 2>/dev/null || true; \
	else \
		echo "(script directories differ or missing)"; \
	fi
	@if diff -q "$(HERDR_HOME_CONFIG)" "$(HERDR_REPO_CONFIG)" >/dev/null 2>&1 && \
		diff -rq "$(HERDR_HOME_DIR)/scripts" "$(HERDR_REPO_DIR)/scripts" >/dev/null 2>&1; then \
		echo "✅ You are up to date with the configuration! 🎉"; \
	fi

herdr-remove-backups:
	@set -- .herdr-*/; \
	if [ ! -d "$$1" ]; then echo "ℹ️  No Herdr backups found."; exit 0; fi; \
	if [ ! -t 0 ]; then echo "⚠️  No terminal: nothing deleted. Rerun interactively."; exit 0; fi; \
	printf "🗑  Delete %s Herdr backup(s)? [y/N] " "$$#"; read -r answer; \
	case "$$answer" in [yY]|[yY][eE][sS]) ;; *) echo "✅ Aborted — no backups deleted."; exit 0;; esac; \
	for b in "$$@"; do echo "🗑  $$b"; rm -rf "$$b"; done; echo "✅ Removed Herdr backups."

# ============================================================
# CONVENIENCE ALIASES
# ============================================================

sync: doom-sync tmux-sync openclaw-sync opencode-sync herdr-global-set
	@echo "✅ All configurations synced!"

backup: doom-backup tmux-backup openclaw-backup opencode-backup herdr-global-backup

restore: doom-restore tmux-restore openclaw-restore opencode-restore herdr-global-restore

# ============================================================
# TESTING
# ============================================================

soft-test:
	@bash ./test-local.sh

# ============================================================
# HELP
# ============================================================

help:
	@echo "CachyOS Setup - Available Targets"
	@echo "=================================="
	@echo
	@echo "ALL:"
	@echo "  make all              Sync Doom Emacs and opencode configs"
	@echo
	@echo "DOOM EMACS:"
	@echo "  make doom-sync        Backup and sync Doom Emacs config"
	@echo "  make doom-backup      Backup current ~/.doom.d"
	@echo "  make doom-restore     Restore most recent Doom backup"
	@echo
	@echo "TMUX:"
	@echo "  make tmux-sync        Backup and sync tmux config, install TPM"
	@echo "  make tmux-backup      Backup current ~/.tmux.conf"
	@echo "  make tmux-restore     Restore most recent tmux backup"
	@echo "  make tmux-diff        Show differences between repo and installed"
	@echo
	@echo "OPENCLAW:"
	@echo "  make openclaw-backup  Save ~/.openclaw/ config to repo"
	@echo "  make openclaw-sync    Deploy repo config to ~/.openclaw/ (with backup)"
	@echo "  make openclaw-restore Restore most recent OpenClaw backup"
	@echo
	@echo "OPENCODE:"
	@echo "  make opencode-backup  Backup current ~/.config/opencode"
	@echo "  make opencode-sync    Deploy repo .opencode/ to ~/.config/opencode (with backup)"
	@echo "  make opencode-restore Restore most recent opencode backup"
	@echo "  make opencode-diff    Show differences between repo and installed"
	@echo
	@echo "GLOBAL AGENT SKILLS:"
	@echo "  make add_pocock_skills    Install/update Pocock skills globally"
	@echo "  make delete_pocock_skills Remove Pocock skill links and private cache"
	@echo "  make purge-claude-skills  Remove all skills inside ~/.claude/skills"
	@echo "  make purge-opencode-skills  Remove all skills inside ~/.config/opencode/skills"
	@echo
	@echo "CHECKS:"
	@echo "  make check-skills-mirror  Verify .opencode/ and .claude/ skills and commands stay in sync"
	@echo
	@echo "MERMAID:"
	@echo "  make mermaid-install   Install the pinned Mermaid CLI"
	@echo "  make mermaid-check     Validate Mermaid diagrams with Mermaid CLI"
	@echo
	@echo "HERDR:"
	@echo "  make herdr-global-set      Deploy Herdr config and Fish helpers (with backup)"
	@echo "  make herdr-global-unset    Remove ~/.config/herdr/config.toml (with backup)"
	@echo "  make herdr-global-backup   Backup ~/.config/herdr/config.toml to ./.herdr-<timestamp>/"
	@echo "  make herdr-global-restore  Restore the most recent Herdr config backup"
	@echo "  make herdr-global-diff     Show differences between repo and installed Herdr config"
	@echo "  make herdr-remove-backups  Delete ./.herdr-* backups (asks first)"
	@echo
	@echo "TESTING:"
	@echo "  make soft-test        Validate Fish scripts (syntax, structure, README catalog, rerun safety)"
	@echo
	@echo "SHORTCUTS:"
	@echo "  make sync             Sync all configs (Doom, Tmux, OpenClaw, opencode)"
	@echo "  make backup           Backup all configs"
	@echo "  make restore          Restore all from most recent backups"
	@echo
	@echo "HELP:"
	@echo "  make help             Show this help message"
