# =============================================================================
# ~/.zshrc → symlink from ~/.dotfiles/shell/.zshrc
#
# Interactive shell configuration.
# Runs every time a new terminal opens.
# Cross-platform: macOS (Apple Silicon + Intel) and Linux.
# =============================================================================

# ── Homebrew ─────────────────────────────────────────────────────────────────
# Also in .zprofile — VS Code / terminal emulators open non-login shells that skip .zprofile
[ -f "$HOME/.brew_env" ] && source "$HOME/.brew_env"

# ── uv (Python manager) ──────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Dev root ─────────────────────────────────────────────────────────────────
export DEV="$HOME/dev"

# ── zoxide — smarter cd ───────────────────────────────────────────────────────
# Usage: z dotfiles   (jumps to most-used matching directory)
# Usage: zi           (interactive fuzzy picker)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ── fzf — fuzzy finder ───────────────────────────────────────────────────────
# Ctrl+R → fuzzy search through command history
# Ctrl+T → fuzzy search files, paste into command line
if command -v fzf &>/dev/null; then
  _fzf_dir="$(brew --prefix 2>/dev/null)/opt/fzf/shell"
  [ -f "$_fzf_dir/key-bindings.zsh" ] && source "$_fzf_dir/key-bindings.zsh"
  [ -f "$_fzf_dir/completion.zsh"   ] && source "$_fzf_dir/completion.zsh"
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ── direnv — per-project env vars ────────────────────────────────────────────
# Create a .envrc in any project to auto-load env vars when you cd in.
# Usage: echo 'export API_KEY=xyz' > .envrc && direnv allow
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# ── Starship prompt ──────────────────────────────────────────────────────────
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ── History ──────────────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS     # skip duplicate adjacent entries
setopt HIST_IGNORE_SPACE    # prefix command with space to skip history
setopt SHARE_HISTORY        # share history across all open sessions

# ── Completion ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit

# ── Aliases ──────────────────────────────────────────────────────────────────
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# ── Machine-specific overrides ───────────────────────────────────────────────
# ~/.zshrc.local is sourced here but NEVER committed to git.
# Use it for: work env vars, VPN aliases, machine-specific API key paths,
# auto-activating work environments, anything that differs between machines.
#
# Example ~/.zshrc.local for work:
#   export WORK_DB_URL="postgresql://..."
#   source /opt/work-tools/env.sh
#   alias vpn="openconnect vpn.company.com"
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
