#!/usr/bin/env bash
# Bootstrap from a fresh machine — no git required.
# Usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/JLFrick/dotfiles/main/remote-install.sh)"
set -euo pipefail

REPO="https://github.com/JLFrick/dotfiles"
TARGET="$HOME/.dotfiles"

is_executable() { type "$1" > /dev/null 2>&1; }

if [ -d "$TARGET/.git" ]; then
  echo "~/.dotfiles already exists — pulling latest"
  git -C "$TARGET" pull --rebase
elif is_executable git; then
  git clone "$REPO" "$TARGET"
elif is_executable curl; then
  mkdir -p "$TARGET"
  curl -sL "$REPO/archive/main.tar.gz" | tar -xz -C "$TARGET" --strip-components=1
elif is_executable wget; then
  mkdir -p "$TARGET"
  wget -qO- "$REPO/archive/main.tar.gz" | tar -xz -C "$TARGET" --strip-components=1
else
  echo "Error: need git, curl, or wget" && exit 1
fi

bash "$TARGET/bootstrap.sh" "$@"
