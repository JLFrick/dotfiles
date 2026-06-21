# dotfiles

Personal development environment for macOS and Linux. One command from a
fresh machine to a fully configured setup.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/JLFrick/dotfiles/main/remote-install.sh)"
```

Or if you already have git:

```bash
git clone https://github.com/JLFrick/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/bootstrap.sh
```

---

## File structure

```
~/.dotfiles/
│
├── bootstrap.sh            Entry point. Cross-platform. Accepts profile flags.
├── macos/
│   └── macos.sh            macOS-specific system preferences.
├── Makefile                Task runner: install, update, save, list, clean.
├── .gitignore              Repo-level ignores (backups, local overrides).
├── LICENSE
│
├── brew/
│   ├── Brewfile            Core CLI tools — every machine, every profile.
│   ├── Brewfile.personal   GUI apps + fonts — personal Mac only.
│   └── Brewfile.work       Work-specific tools — work profile only.
│
├── shell/
│   ├── .zshrc              Interactive shell: tools, prompt, history, aliases.
│   ├── .zprofile           Login shell: PATH and env vars (runs once at login).
│   ├── .brew_env           Homebrew path detection — shared by .zshrc and .zprofile.
│   └── .aliases            All shortcuts in one file.
│
├── git/
│   ├── .gitconfig          Global git: identity, editor, delta diffs, aliases.
│   └── .gitignore_global   Patterns ignored in every repo on this machine.
│
├── editor/
│   ├── settings.json       VS Code settings.
│   ├── keybindings.json    Custom shortcuts.
│   └── .editorconfig       Cross-editor indentation and whitespace rules.
│
├── ai/
│   ├── claude/
│   │   └── CLAUDE.md       Global Claude Code instructions (read each session).
│   └── codex/
│       └── AGENTS.md       OpenAI Codex instructions template (per-project).
│
├── config/
│   └── starship.toml       Terminal prompt: git, Python, timing.
│
└── bin/
    └── new-project.sh      Scaffold any project in one command.
```

---

## Profiles

Three install profiles control what gets installed:

| Profile | Command | Installs |
|---------|---------|----------|
| `personal` | `make install` | Core CLI + GUI apps + fonts |
| `minimal` | `make install-minimal` | Core CLI only |
| `work` | `make install-work` | Core CLI + Brewfile.work |

**Personal** is the default and what you run on your Mac. **Minimal** is for
work machines or servers where you cannot or don't want to install GUI apps.
**Work** is for a work Mac that needs specific tooling on top of the core CLI.

Machine-specific runtime differences (work env vars, auto-activating
environments, VPN aliases) go in `~/.zshrc.local` — it's sourced by `.zshrc`
but never committed.

---

## How syncing works

### The symlink model

`bootstrap.sh` creates symlinks, not copies. `~/.zshrc` is a pointer to
`~/.dotfiles/shell/.zshrc`. They are the same file.

```
~/.zshrc                      →  ~/.dotfiles/shell/.zshrc
~/.gitconfig                  →  ~/.dotfiles/git/.gitconfig
~/.claude/CLAUDE.md           →  ~/.dotfiles/ai/claude/CLAUDE.md
~/.config/starship.toml       →  ~/.dotfiles/config/starship.toml
~/Library/.../Code/User/settings.json  →  ~/.dotfiles/editor/settings.json
```

Editing `~/.zshrc` directly and editing `~/.dotfiles/shell/.zshrc` are
identical operations on the same bytes. There is no sync lag.

### Making and saving changes

```bash
# Option 1: edit via alias (opens dotfiles repo in VS Code)
dotfiles
# make your changes, save

# Option 2: edit the live path directly (same file via symlink)
code ~/.zshrc

# Either way: commit and push
dotfiles-save
# or: make -C ~/.dotfiles save
```

### Pulling changes on another machine

```bash
dotfiles-update
# or: make -C ~/.dotfiles update
# Runs: git pull --rebase, then re-runs bootstrap for any new files
```

---

## Daily commands

```bash
dotfiles           # open this repo in VS Code
dotfiles-save      # commit + push all changes
dotfiles-update    # pull latest + re-bootstrap
make list          # show all active symlinks
new-project name
```

---

## Machine-specific config

`~/.zshrc.local` is sourced by `.zshrc` but never committed. Use it for
anything that differs between machines:

```zsh
# ~/.zshrc.local — work machine example
export COMPANY_DB_URL="postgresql://..."
source /opt/work-tools/activate.sh
alias vpn="openconnect vpn.company.com"

# Auto-activate a work Python environment
source /opt/work-venv/bin/activate
```

SSH keys follow the same rule — never committed. Restore from your password
manager to `~/.ssh/` on each machine.

---

## Fonts

The JetBrains Mono Nerd Font is installed via `Brewfile.personal`.
It is required for Starship prompt icons, eza file icons, and VS Code
material-icon-theme to render correctly.

After installing, set your terminal font in VS Code:
`terminal.integrated.fontFamily` is already set to `JetBrainsMono Nerd Font`
in `editor/settings.json`.

If the font is not set, your prompt will show broken boxes instead of icons.

---

## New machine setup

```bash
# Option A — no git required (uses curl/wget fallback)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/JLFrick/dotfiles/main/remote-install.sh)"
# pass a profile flag:
bash -c "$(curl -fsSL https://raw.githubusercontent.com/JLFrick/dotfiles/main/remote-install.sh)" -- --minimal

# Option B — manual clone
git clone https://github.com/JLFrick/dotfiles.git ~/.dotfiles
bash ~/.dotfiles/bootstrap.sh          # personal Mac (default)
bash ~/.dotfiles/bootstrap.sh --minimal  # work or server

# After restart:
#   a. Update email:  code ~/.dotfiles/git/.gitconfig
#   b. GitHub auth:   gh auth login
#   c. SSH keys:      restore from password manager → ~/.ssh/
#   d. Terminal font: set "JetBrainsMono Nerd Font" in VS Code settings
```

---

## Tested on

- macOS 14+ Apple Silicon (M-series)
- macOS 13+ Intel
- Ubuntu 22.04+
