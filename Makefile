# === Makefile for Doom Emacs config sync ===
# Moves existing ~/.doom.d to a timestamped backup and installs new config
# Supports restore from the most recent backup

.PHONY: sync backup restore healthcheck

# Generate timestamp in format YYYY_mm_dd_hh_MM
TIMESTAMP := $(shell date +"%Y_%m_%d_%H_%M")
BACKUP_DIR := $(HOME)/.doom.d_backup_$(TIMESTAMP)

sync: backup
	@echo "📦 Copying new Doom Emacs configuration..."
	@cp -r ./.doom.d $(HOME)/.doom.d
	@doom sync
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

healthcheck:
	@echo "=== CachyOS Setup Healthcheck ==="
	@echo
	@passed=0; \
	failed=0; \
	total=0; \
	\
	# Git Setup Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Git Setup..."; \
	if command -v git >/dev/null 2>&1; then \
		git_version=$$(git --version 2>/dev/null | head -n1); \
		echo "  ✓ Binary: $$git_version"; \
		if [ -f "$(HOME)/.ssh/id_ed25519" ]; then \
			echo "  ✓ SSH Key: ~/.ssh/id_ed25519 exists"; \
		else \
			echo "  ✗ SSH Key: ~/.ssh/id_ed25519 not found"; \
		fi; \
		if git config --global user.name >/dev/null 2>&1 && git config --global user.email >/dev/null 2>&1; then \
			echo "  ✓ Git Config: user.name and user.email configured"; \
		else \
			echo "  ✗ Git Config: user.name or user.email not configured"; \
		fi; \
		if ssh-add -l >/dev/null 2>&1; then \
			echo "  ✓ SSH Agent: keys loaded"; \
		else \
			echo "  ⚠ SSH Agent: no keys loaded"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] Git Setup - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Git Setup - FAILED (git not found)"; \
	fi; \
	echo; \
	\
	# Mise Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Mise..."; \
	if command -v mise >/dev/null 2>&1; then \
		mise_version=$$(mise --version 2>/dev/null | head -n1); \
		echo "  ✓ Binary: $$mise_version"; \
		if grep -q "mise activate fish" ~/.config/fish/config.fish 2>/dev/null; then \
			echo "  ✓ Config: Fish activation found in config.fish"; \
		else \
			echo "  ✗ Config: Fish activation not found in config.fish"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] Mise - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Mise - FAILED (mise not found)"; \
	fi; \
	echo; \
	\
	# Ollama Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Ollama..."; \
	if command -v ollama >/dev/null 2>&1; then \
		ollama_version=$$(ollama --version 2>/dev/null | head -n1); \
		echo "  ✓ Binary: $$ollama_version"; \
		if systemctl --user is-active ollama >/dev/null 2>&1 || systemctl is-active ollama >/dev/null 2>&1; then \
			echo "  ✓ Service: Ollama service is running"; \
		else \
			echo "  ⚠ Service: Ollama service not running"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] Ollama - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Ollama - FAILED (ollama not found)"; \
	fi; \
	echo; \
	\
	# Podman Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Podman..."; \
	if command -v podman >/dev/null 2>&1; then \
		podman_version=$$(podman --version 2>/dev/null | head -n1); \
		echo "  ✓ Binary: $$podman_version"; \
		if systemctl --user is-active podman.socket >/dev/null 2>&1; then \
			echo "  ✓ Socket: Podman socket is active"; \
		else \
			echo "  ⚠ Socket: Podman socket not active"; \
		fi; \
		if [ -f ~/.config/fish/functions/docker.fish ]; then \
			echo "  ✓ Docker Function: docker function exists"; \
		else \
			echo "  ✗ Docker Function: docker function not found"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] Podman - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Podman - FAILED (podman not found)"; \
	fi; \
	echo; \
	\
	# Doom Emacs Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Doom Emacs..."; \
	if [ -d "$(HOME)/.emacs.d" ]; then \
		echo "  ✓ Doom Emacs: ~/.emacs.d exists"; \
		if [ -d "$(HOME)/.doom.d" ]; then \
			echo "  ✓ Doom Config: ~/.doom.d exists"; \
		else \
			echo "  ✗ Doom Config: ~/.doom.d not found"; \
		fi; \
		if command -v doom >/dev/null 2>&1; then \
			doom_version=$$(doom --version 2>/dev/null | head -n1); \
			echo "  ✓ Doom CLI: $$doom_version"; \
		else \
			echo "  ✗ Doom CLI: doom command not found"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] Doom Emacs - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Doom Emacs - FAILED (~/.emacs.d not found)"; \
	fi; \
	echo; \
	\
	# Cursor Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Cursor..."; \
	if [ -f "$(HOME)/opt/cursor.appimage" ]; then \
		echo "  ✓ AppImage: ~/opt/cursor.appimage exists"; \
		if [ -L /usr/local/bin/cursor ]; then \
			echo "  ✓ Symlink: /usr/local/bin/cursor symlink exists"; \
		else \
			echo "  ✗ Symlink: /usr/local/bin/cursor symlink not found"; \
		fi; \
		if [ -f /usr/share/applications/cursor.desktop ]; then \
			echo "  ✓ Desktop Entry: cursor.desktop exists"; \
		else \
			echo "  ✗ Desktop Entry: cursor.desktop not found"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] Cursor - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Cursor - FAILED (~/opt/cursor.appimage not found)"; \
	fi; \
	echo; \
	\
	# GitHub CLI Check \
	total=$$((total + 1)); \
	echo "🔍 Checking GitHub CLI..."; \
	if command -v gh >/dev/null 2>&1; then \
		gh_version=$$(gh --version 2>/dev/null | head -n1); \
		echo "  ✓ Binary: $$gh_version"; \
		if gh auth status >/dev/null 2>&1; then \
			gh_user=$$(gh api user --jq .login 2>/dev/null || echo "unknown"); \
			echo "  ✓ Auth: Authenticated as $$gh_user"; \
		else \
			echo "  ⚠ Auth: Not authenticated (run 'gh auth login')"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] GitHub CLI - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] GitHub CLI - FAILED (gh not found)"; \
	fi; \
	echo; \
	\
	# Ngrok Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Ngrok..."; \
	if command -v ngrok >/dev/null 2>&1; then \
		ngrok_version=$$(ngrok version 2>/dev/null | head -n1); \
		echo "  ✓ Binary: $$ngrok_version"; \
		if [ -d ~/.config/ngrok ]; then \
			echo "  ✓ Config: ~/.config/ngrok directory exists"; \
		else \
			echo "  ✗ Config: ~/.config/ngrok directory not found"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] Ngrok - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Ngrok - FAILED (ngrok not found)"; \
	fi; \
	echo; \
	\
	# Vivaldi Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Vivaldi..."; \
	if command -v vivaldi >/dev/null 2>&1; then \
		vivaldi_version=$$(vivaldi --version 2>/dev/null | head -n1); \
		echo "  ✓ Binary: $$vivaldi_version"; \
		passed=$$((passed + 1)); \
		echo "  [✓] Vivaldi - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Vivaldi - FAILED (vivaldi not found)"; \
	fi; \
	echo; \
	\
	# Elixir/Erlang Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Elixir/Erlang..."; \
	if command -v elixir >/dev/null 2>&1 && command -v erl >/dev/null 2>&1; then \
		elixir_version=$$(elixir -v 2>/dev/null | grep "Elixir" | awk '{print $$2}' || echo "unknown"); \
		erlang_version=$$(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell 2>/dev/null || echo "unknown"); \
		echo "  ✓ Elixir: v$$elixir_version"; \
		echo "  ✓ Erlang: OTP $$erlang_version"; \
		if grep -q "mise activate fish" ~/.config/fish/config.fish 2>/dev/null; then \
			echo "  ✓ Mise Config: Fish activation found"; \
		else \
			echo "  ✗ Mise Config: Fish activation not found"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] Elixir/Erlang - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Elixir/Erlang - FAILED (elixir or erl not found)"; \
	fi; \
	echo; \
	\
	# Act Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Act..."; \
	if command -v act >/dev/null 2>&1; then \
		act_version=$$(act --version 2>/dev/null | head -n1); \
		echo "  ✓ Binary: $$act_version"; \
		if [ -d ~/.act ]; then \
			echo "  ✓ Config: ~/.act directory exists"; \
		else \
			echo "  ✗ Config: ~/.act directory not found"; \
		fi; \
		if command -v docker >/dev/null 2>&1; then \
			echo "  ✓ Docker: Docker available for act"; \
		else \
			echo "  ⚠ Docker: Docker not available"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] Act - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Act - FAILED (act not found)"; \
	fi; \
	echo; \
	\
	# Emacs Check \
	total=$$((total + 1)); \
	echo "🔍 Checking Emacs..."; \
	if command -v emacs >/dev/null 2>&1; then \
		emacs_version=$$(emacs --version 2>/dev/null | head -n1); \
		echo "  ✓ Binary: $$emacs_version"; \
		passed=$$((passed + 1)); \
		echo "  [✓] Emacs - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] Emacs - FAILED (emacs not found)"; \
	fi; \
	echo; \
	\
	# ElixirLS Check \
	total=$$((total + 1)); \
	echo "🔍 Checking ElixirLS..."; \
	if [ -f ~/.local/share/elixir-ls/language_server.sh ]; then \
		echo "  ✓ Binary: ~/.local/share/elixir-ls/language_server.sh exists"; \
		if grep -q "elixir-ls" ~/.config/fish/config.fish 2>/dev/null; then \
			echo "  ✓ Config: ElixirLS PATH configured in Fish"; \
		else \
			echo "  ✗ Config: ElixirLS PATH not configured"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] ElixirLS - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] ElixirLS - FAILED (language_server.sh not found)"; \
	fi; \
	echo; \
	\
	# PDF Support Check \
	total=$$((total + 1)); \
	echo "🔍 Checking PDF Support..."; \
	if command -v xournalpp >/dev/null 2>&1; then \
		xournalpp_version=$$(xournalpp --version 2>/dev/null | head -n1); \
		echo "  ✓ Xournal++: $$xournalpp_version"; \
		if pacman -Q poppler-glib >/dev/null 2>&1; then \
			echo "  ✓ Poppler: PDF rendering support available"; \
		else \
			echo "  ✗ Poppler: PDF rendering support missing"; \
		fi; \
		passed=$$((passed + 1)); \
		echo "  [✓] PDF Support - PASSED"; \
	else \
		failed=$$((failed + 1)); \
		echo "  [✗] PDF Support - FAILED (xournalpp not found)"; \
	fi; \
	echo; \
	\
	# Summary \
	echo "=== Summary ==="; \
	echo "Passed: $$passed/$$total"; \
	echo "Failed: $$failed/$$total"; \
	echo; \
	if [ $$failed -eq 0 ]; then \
		echo "🎉 All installations verified successfully!"; \
		exit 0; \
	else \
		echo "⚠️  Some installations failed verification."; \
		echo "💡 Run the corresponding .fish scripts to fix failed installations."; \
		exit 1; \
	fi
