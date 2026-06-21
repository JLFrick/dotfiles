# Claude Code — Global Instructions

## Identity

Quantitative researcher and AI engineer.
macOS Apple Silicon (M4 Air) | Python: uv-managed, `.venv` per project

---

## Behavioral Guardrails

### 1 — Think Before Coding
Don't assume. Don't hide confusion. Surface tradeoffs.

- State assumptions explicitly before implementing. If uncertain, ask.
- If multiple interpretations exist, present them—don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2 — Simplicity First
Minimum code that solves the problem. Nothing speculative.

- No feature beyond what was asked.
- No abstractions for single-use code.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: _"Would a senior engineer say this is overcomplicated?"_ If yes, simplify.

### 3 — Surgical Changes
Touch only what you must. Clean up only your own mess.

- Don't improve adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it—don't delete it silently.
- Remove only imports/variables YOUR changes made unused.

**The test:** Every changed line must trace directly to the user's request.

### 4 — Goal-Driven Execution
Define success criteria. Loop until verified.

Transform vague tasks into verifiable goals:
- "Fix the bug" → write a test that reproduces it, then make it pass.
- "Add validation" → define invalid inputs, write tests, make them pass.
- "Refactor X" → ensure tests pass before and after.

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

### 5 — Plan-First Execution & Zero-Drift Docs
Write it down before you build it. Update it when you change it.

- **Plan First**: For any multi-file or complex architectural change, draft a step-by-step markdown plan before writing code.
- **Continuous Sync**: If we pivot during implementation, update the plan immediately. The written plan must always reflect the current reality, not the original intent.
- **Zero-Drift**: When modifying code, update the corresponding documentation, wiki, or architecture files in the exact same step. Do not leave documentation updates for "later."
- **Knowledge Portability**: Keep planning and architectural documents in standard Markdown with clean hierarchical headings so they can be easily synced to external knowledge bases.

---

## Git Safety

- **NEVER** commit without explicit approval.
- Before any `git commit` or `git push`: state what changed and wait for confirmation.
- Never amend published commits, force-push, or reset without explicit instruction.

---

## Code Style (Universal)

- **Functional over OOP**: prefer pure functions; classes only for external connectors.
- **Type hints** on every function signature—no exceptions.
- **Explicit errors**: raise exceptions with informative messages. Never swallow silently.
- **No global state**: pass state explicitly.
- **No fallbacks or symptom-masking** unless I explicitly ask.
- **Structured logging**: use `logging` module with fields—never `print()`.

---

## Python Toolchain (All Projects)

| Use | Instead of |
|-----|-----------|
| `uv add` / `uv pip install` | `pip install` |
| `pathlib.Path` | `os.path` |
| `polars` for new DataFrame work | `pandas` |
| `httpx` | `requests` |
| `logging` | `print()` |

After generating Python code, always remind me:
```bash
uv run ruff check .
uv run ruff format .
uv run pytest
```

---

## Anti-Patterns — Never

- `sys.path.insert` — never hack the import path.
- Global variables — pass state explicitly.
- Silent failures — always raise explicitly.
- Speculative abstractions (YAGNI).
- Backwards-compatibility shims for removed code.

---

## Documentation Discipline

- No inline comments unless the WHY is non-obvious (a hidden constraint, subtle invariant, or workaround).
- No multi-paragraph docstrings; one short line max on public functions.
- No planning or analysis documents unless I ask.
- Code and well-named identifiers are the primary documentation.
