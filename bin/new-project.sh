#!/usr/bin/env bash
# Usage: new-project <name>
set -euo pipefail
NAME="${1:?Usage: new-project <name>}"
PROJECT_DIR="${DEV:-$HOME/dev}/$NAME"
BOLD="$(tput bold)"; RESET="$(tput sgr0)"; GREEN='\033[0;32m'; NC='\033[0m'
ok() { echo -e "  ${GREEN}✓${NC} $1"; }

echo; echo "${BOLD}$NAME${RESET}  ~/dev/$NAME"
mkdir -p "$PROJECT_DIR" && cd "$PROJECT_DIR"
git init -b main && ok "git"
uv init --no-readme && rm -f hello.py
uv python pin 3.12
uv add --dev ruff pytest pytest-cov ipykernel && ok "uv (Python 3.12)"
mkdir -p src tests notebooks data/{raw,processed}
touch src/__init__.py tests/__init__.py
printf 'raw/*\n!raw/.gitkeep\nprocessed/*\n!processed/.gitkeep\n' > data/.gitignore
touch data/raw/.gitkeep data/processed/.gitkeep && ok "folders"
cat >> pyproject.toml << 'TOML'

[tool.ruff]
line-length = 100
target-version = "py312"
[tool.ruff.lint]
select = ["E", "F", "I", "UP"]
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts   = "--tb=short"
TOML
ok "ruff + pytest"
mkdir -p .devcontainer
cat > .devcontainer/devcontainer.json << DCJSON
{
  "name": "$NAME",
  "image": "mcr.microsoft.com/devcontainers/python:3.12",
  "postCreateCommand": "pip install uv && uv sync",
  "customizations": {
    "vscode": {
      "extensions": ["ms-python.python", "charliermarsh.ruff", "ms-toolsai.jupyter"],
      "settings": { "python.defaultInterpreterPath": ".venv/bin/python" }
    }
  }
}
DCJSON
ok "devcontainer"
printf '# Copy to .env\n# API_KEY=\n' > .env.example
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << 'YML'
name: CI
on:
  push:         { branches: [main] }
  pull_request: { branches: [main] }
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v4
      - run: uv python install
      - run: uv sync --dev
      - run: uv run ruff check .
      - run: uv run ruff format --check .
      - run: uv run pytest
YML
ok "GitHub Actions CI"
printf '# %s\n\n## Setup\n```bash\nuv sync\n```\n' "$NAME" > README.md
printf 'def test_placeholder() -> None:\n    assert True\n' > tests/test_placeholder.py
git add -A && git commit -m "init: scaffold $NAME" && ok "initial commit"
if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
  read -rp "  Create private GitHub repo? [Y/n] " ans
  [[ "${ans:-y}" =~ ^[Yy]$ ]] && gh repo create "$NAME" --private --source=. --push && ok "GitHub"
fi
echo; echo "${BOLD}Done:${RESET} $PROJECT_DIR"
command -v code &>/dev/null && code "$PROJECT_DIR"
