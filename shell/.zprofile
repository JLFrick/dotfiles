# =============================================================================
# ~/.zprofile → symlink from ~/.dotfiles/shell/.zprofile
#
# Login shell configuration.
# Runs ONCE at login (not on every terminal open).
# Put PATH additions and env vars here — not in .zshrc.
# Separation keeps terminal startup fast.
# =============================================================================

# ── Homebrew ─────────────────────────────────────────────────────────────────
[ -f "$HOME/.brew_env" ] && source "$HOME/.brew_env"

# ── uv ───────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Default editor ───────────────────────────────────────────────────────────
# Used by git commit, crontab -e, and other tools that open an editor.
export EDITOR="code --wait"
export VISUAL="$EDITOR"

# ── Locale ───────────────────────────────────────────────────────────────────
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
