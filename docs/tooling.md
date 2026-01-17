# Tooling & Automation

This page covers tools and workflows for Godot + GDScript + Rust development.

## Quick Reference

| Command | Description |
|---------|-------------|
| `make dev-ci` | Full CI in Docker (recommended) |
| `make dev-fixtures` | Run GDScript fixture tests in Docker |
| `make dev-validate` | Verify tools + run full CI |
| `make dev-shell` | Interactive shell in container |
| `make ci` | Full local CI (requires local tools) |
| `make fixtures` | Run GDScript fixture tests locally |
| `make gdscript-ci` | Smoke + fixtures (GDScript only) |

## Docker Dev Environment (Recommended)

The Docker container includes all tools pre-configured:
- Rust 1.92 + clippy + rustfmt
- Godot 4.5.1 headless (ARM64/x86_64 auto-detected)
- Python 3.11 + uv

```bash
# First time setup
make dev-validate

# Daily workflow
make dev-ci          # Full validation
make dev-fixtures    # Just GDScript tests
make dev-shell       # Interactive debugging
```

## GDScript Fixture Testing

Fixtures are JSON files that define deterministic test cases:

```json
{
  "initial_state": { "tick": 0 },
  "input": { "delta": 2 },
  "expected_state": { "tick": 2 }
}
```

Place fixtures in `godot/tests/fixtures/` and run:
```bash
make dev-fixtures
```

Expected output:
```
[FIXTURE OK] step_basic.json
[FIXTURES OK] 3 passed
```

## Rust Tooling

Install Rust and enable fmt/clippy:
```bash
rustup default stable
rustup component add clippy rustfmt
```

Core tests:
```bash
cargo test -p core
```

## Makefile Commands

### GDScript Commands
```bash
make fixtures      # Run fixture tests
make gdscript-ci   # Smoke + fixtures
make smoke         # Build extension + smoke test
```

### Rust Commands
```bash
make fmt           # Format Rust code
make lint          # Run clippy
make test          # Run core tests
make build-ext     # Build GDExtension
```

### Docker Commands
```bash
make dev-ci            # Full CI in container
make dev-fixtures      # Fixtures in container
make dev-validate      # Tools check + full CI
make dev-shell         # Interactive bash
make dev-check-tools   # Verify tool versions
```

## Recommended Plugins

- **GDUnit4** or **GUT** for automated tests
- **Dialogic** for narrative-heavy projects
- **Godot-Redux** or custom input remapping for accessibility

Keep plugins in `godot/addons/` and commit to version control.

## GDScript Formatting & Linting

Suggested tools:
- **gdformat** (formatter)
- **gdlint** (lint rules)

```bash
pip install godot-gdscript-toolkit
gdformat godot/scripts
gdlint godot/scripts
```

## Headless Testing

Godot headless mode is used for CI:
```bash
# Smoke test
godot --headless --path godot --script res://scripts/smoke_test.gd

# Fixture tests
godot --headless --path godot --script res://scripts/run_fixtures.gd
```

## Build Checklist

- ✅ Rust fmt + clippy pass
- ✅ `cargo test -p core` passes
- ✅ Extension builds and copies into `godot/addons/my_ext/bin/`
- ✅ Headless smoke test passes
- ✅ GDScript fixture tests pass
