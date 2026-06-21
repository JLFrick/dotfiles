#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — dotfiles installer
#
# Usage:
#   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
#   bash ~/.dotfiles/bootstrap.sh [--personal|--minimal|--work]
#
# Profiles:
#   --personal  (default) Full setup: CLI tools + GUI apps + fonts
#   --minimal   CLI tools only. Use on work machines or servers.
#   --work      CLI tools + work-specific Brewfile. No personal GUI apps.
#
# Safe to re-run — skips steps already done.
# Supports: macOS (Apple Silicon + Intel), Linux (Debian/Ubuntu, Arch)
# =============================================================================

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
OS="$(uname -s)"

# ── Colours ──────────────────────────────────────────────────────────────────
BOLD="$(tput bold 2>/dev/null || true)"; RESET="$(tput sgr0 2>/dev/null || true)"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step()  { echo; echo "${BOLD}▶  $1${RESET}"; }
ok()    { echo -e "  ${GREEN}✓${NC}  $1"; }
skip()  { echo -e "  ${YELLOW}–${NC}  $1 (skipped)"; }
warn()  { echo -e "  ${YELLOW}!${NC}  $1"; }
fail()  { echo -e "  ${RED}✗${NC}  $1"; exit 1; }

# ── Profile ──────────────────────────────────────────────────────────────────
PROFILE="personal"
for arg in "$@"; do
  case $arg in
    --personal) PROFILE="personal" ;;
    --minimal)  PROFILE="minimal"  ;;
    --work)     PROFILE="work"     ;;
    *) warn "Unknown flag: $arg (ignored)" ;;
  esac
done
echo; echo "${BOLD}Dotfiles bootstrap — profile: ${PROFILE}${RESET}"
echo "  Dotfiles: $DOTFILES"
echo "  OS:       $OS"

# =============================================================================
# Symlink helper
# Usage: symlink "relative/path/in/dotfiles"  "relative/path/from/home"
# =============================================================================
symlink() {
  local src="$DOTFILES/$1"
  local dst="$HOME/$2"
  [ -f "$src" ] || [ -d "$src" ] || { warn "Missing: dotfiles/$1 — skipping"; return 0; }
  mkdir -p "$(dirname "$dst")"
  # Already correct symlink
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then skip "$2"; return 0; fi
  # Back up real file
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.bak.$(date +%Y%m%d_%H%M%S)"
    warn "Backed up $2"
  fi
  [ -L "$dst" ] && rm "$dst"
  ln -sf "$src" "$dst"
  ok "$2  →  dotfiles/$1"
}

# =============================================================================
# 1. OS detection
# =============================================================================
step "Environment"
case "$OS" in
  Darwin)
    if [ "$(uname -m)" = "arm64" ]; then BREW_PREFIX="/opt/homebrew"
    else BREW_PREFIX="/usr/local"; fi
    ok "macOS — Homebrew at $BREW_PREFIX"
    ;;
  Linux)
    BREW_PREFIX="/home/linuxbrew/.linuxbrew"
    ok "Linux — Homebrew at $BREW_PREFIX"
    ;;
  *) fail "Unsupported OS: $OS" ;;
esac

# =============================================================================
# 2. Xcode CLI tools (macOS only)
# =============================================================================
if [ "$OS" = "Darwin" ]; then
  step "Xcode CLI tools"
  if xcode-select -p &>/dev/null; then skip "Xcode CLI tools"
  else
    xcode-select --install
    echo "  Xcode CLI tools installing. Re-run bootstrap.sh when done."
    exit 0
  fi
fi

# =============================================================================
# 3. Homebrew
# =============================================================================
step "Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  ok "Homebrew installed"
else
  skip "Homebrew ($(brew --version | head -1))"
  brew update --quiet
fi

# Core CLI tools — installed on every profile
step "Core tools (Brewfile)"
brew bundle install --file="$DOTFILES/brew/Brewfile" && ok "Core Brewfile applied"

# Personal: GUI apps + fonts
if [ "$PROFILE" = "personal" ] && [ "$OS" = "Darwin" ]; then
  step "Personal apps + fonts (Brewfile.personal)"
  brew bundle install --file="$DOTFILES/brew/Brewfile.personal" && ok "Personal Brewfile applied"
fi

# Work: work-specific tools
if [ "$PROFILE" = "work" ] && [ -f "$DOTFILES/brew/Brewfile.work" ]; then
  step "Work tools (Brewfile.work)"
  brew bundle install --file="$DOTFILES/brew/Brewfile.work" && ok "Work Brewfile applied"
fi

# =============================================================================
# 4. uv
# =============================================================================
step "uv"
if command -v uv &>/dev/null; then skip "uv ($(uv --version))"
else
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
  ok "uv installed"
fi

# =============================================================================
# 5. npm globals
# =============================================================================
step "npm globals"
if command -v claude &>/dev/null; then skip "claude ($(claude --version 2>/dev/null | head -1))"
else
  npm install -g @anthropic-ai/claude-code
  ok "Claude Code installed"
fi
if command -v ccusage &>/dev/null; then skip "ccusage ($(ccusage --version 2>/dev/null | head -1))"
else
  npm install -g ccusage
  ok "ccusage installed"
fi

# =============================================================================
# 6. Shell config
# =============================================================================
step "Shell"
symlink "shell/.zshrc"    ".zshrc"
symlink "shell/.zprofile" ".zprofile"
symlink "shell/.aliases"  ".aliases"

# =============================================================================
# 7. Git
# =============================================================================
step "Git"
symlink "git/.gitconfig"        ".gitconfig"
symlink "git/.gitignore_global" ".gitignore_global"

# =============================================================================
# 8. Editor — VS Code
# =============================================================================
step "Editor settings"
if [ "$OS" = "Darwin" ]; then
  VSCODE_USER="Library/Application Support/Code/User"
else
  VSCODE_USER=".config/Code/User"
fi

mkdir -p "$HOME/$VSCODE_USER"
symlink "editor/settings.json"    "$VSCODE_USER/settings.json"
symlink "editor/keybindings.json" "$VSCODE_USER/keybindings.json"

if command -v code &>/dev/null && [ -f "$DOTFILES/editor/extensions.txt" ]; then
  while IFS= read -r ext; do
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    code --install-extension "$ext" --force &>/dev/null && ok "$ext"
  done < "$DOTFILES/editor/extensions.txt"
fi

# =============================================================================
# 9. AI — Claude Code + Codex
# =============================================================================
step "AI config"
mkdir -p "$HOME/.claude"
symlink "ai/claude/CLAUDE.md" ".claude/CLAUDE.md"

# Codex global instructions (~/.codex/AGENTS.md)
mkdir -p "$HOME/.codex"
symlink "ai/codex/AGENTS.md" ".codex/AGENTS.md"

# =============================================================================
# 10. Starship prompt + app preferences
# =============================================================================
step "Starship"
mkdir -p "$HOME/.config"
symlink "config/starship.toml" ".config/starship.toml"

step "App preferences"
if [ "$OS" = "Darwin" ] && [ -f "$DOTFILES/config/stats.plist" ]; then
  defaults import eu.exelban.Stats "$DOTFILES/config/stats.plist"
  ok "Stats preferences applied"
fi

# =============================================================================
# 11. macOS preferences (personal + work, skip minimal)
# =============================================================================
if [ "$OS" = "Darwin" ] && [ "$PROFILE" != "minimal" ]; then
  step "macOS preferences"
  read -rp "  Apply macOS system preferences? [y/N] " ans
  [[ "${ans:-n}" =~ ^[Yy]$ ]] && bash "$DOTFILES/macos/macos.sh" && ok "Applied"
fi

# =============================================================================
# 12. Dev folder + scripts
# =============================================================================
step "Dev folder and scripts"
mkdir -p "$HOME/dev/scratch"
ok "~/dev/scratch"
mkdir -p "$HOME/.local/bin"
if [ -f "$DOTFILES/bin/new-project.sh" ]; then
  cp "$DOTFILES/bin/new-project.sh" "$HOME/.local/bin/new-project"
  chmod +x "$HOME/.local/bin/new-project"
  ok "new-project command → ~/.local/bin/new-project"
fi

# =============================================================================
# Done
# =============================================================================
echo
echo "${BOLD}Bootstrap complete.${RESET}  Profile: $PROFILE"
echo
echo "  Next:"
echo "  1. Restart terminal  (or: source ~/.zshrc)"
echo "  2. Set git identity: code $DOTFILES/git/.gitconfig"
echo "  3. GitHub auth:      gh auth login"
echo "  4. SSH keys:         restore from password manager → ~/.ssh/"
[ "$PROFILE" = "personal" ] && echo "  5. Set terminal font: JetBrainsMono Nerd Font (in VS Code + your terminal app)"
