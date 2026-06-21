# =============================================================================
# Makefile — dotfiles task runner
# Usage: make <target>
# Run `make help` to see all available commands.
# =============================================================================

DOTFILES := $(HOME)/.dotfiles

.PHONY: install install-minimal install-work update save list clean help

## install:          Full personal setup (GUI apps + fonts)
install:
	@bash $(DOTFILES)/bootstrap.sh --personal

## install-minimal:  CLI tools only — for work or servers
install-minimal:
	@bash $(DOTFILES)/bootstrap.sh --minimal

## install-work:     Work profile — CLI tools + work Brewfile
install-work:
	@bash $(DOTFILES)/bootstrap.sh --work

## update:           Pull latest from remote + re-run bootstrap
update:
	@echo "Pulling dotfiles..."
	@git -C $(DOTFILES) pull --rebase
	@bash $(DOTFILES)/bootstrap.sh
	@echo "Done. Run: source ~/.zshrc"

## save:             Commit and push all local changes to remote
save:
	@git -C $(DOTFILES) add -A
	@git -C $(DOTFILES) diff --cached --quiet && echo "Nothing to save." || \
		( git -C $(DOTFILES) commit -m "update: $$(date '+%Y-%m-%d %H:%M')" && \
		  git -C $(DOTFILES) push && echo "Saved." )

## list:             Show all active symlinks pointing into dotfiles
list:
	@echo "Active dotfile symlinks:"
	@find $(HOME) -maxdepth 5 -type l 2>/dev/null \
		| while read -r link; do \
			target=$$(readlink "$$link"); \
			echo "$$target" | grep -q "$(DOTFILES)" && \
				printf "  %-55s → %s\n" "$$link" "$$target"; \
		done

## clean:            Remove broken symlinks from home directory
clean:
	@echo "Scanning for broken symlinks..."
	@find $(HOME) -maxdepth 3 -type l ! -exec test -e {} \; -print -delete \
		| sed 's/^/  removed: /' || echo "  None found."

## help:             Show this help
help:
	@echo "Usage: make <target>"; echo
	@grep -E '^## ' Makefile | sed 's/^## /  make /'
