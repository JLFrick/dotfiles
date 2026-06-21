# =============================================================================
# ~/.zprofile → symlink from ~/.dotfiles/shell/.zprofile
#
# Login shell configuration.
# Runs ONCE at login (not on every terminal open).
# Put PATH additions and env vars here — not in .zshrc.
# Separation keeps terminal startup fast.
# =============================================================================

# ── Homebrew ─────────────────────────────────────────────────────────────────
if   [ -f "/opt/homebrew/bin/brew" ];              then eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ];                 then eval "$(/usr/local/bin/brew shellenv)"
elif [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ── uv ───────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Default editor ───────────────────────────────────────────────────────────
# Used by git commit, crontab -e, and other tools that open an editor.
export EDITOR="code --wait"
export VISUAL="$EDITOR"

# ── Locale ───────────────────────────────────────────────────────────────────
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
