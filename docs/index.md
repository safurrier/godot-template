# Godot 4 + GDScript-First Template

Welcome! This template uses **GDScript-first gameplay** with **deterministic seams** for testing, replays, and optional Rust acceleration.

## What You Get

- ✅ **GDScript deterministic seam** in `godot/core/` with `step()`, `decide()`, `generate()`
- ✅ **Fixture testing** with JSON golden tests in `godot/tests/fixtures/`
- ✅ **Docker dev environment** with all tools pre-configured
- ✅ **Optional Rust acceleration** in `rust/` with GDExtension bridge
- ✅ **Automation-first commands** (`make dev-ci` runs everything in Docker)

## Quick Start

```bash
# Docker (recommended) - no local tools needed
make dev-validate

# Or with local tools
make ci
```

Expected output:
```
[FIXTURE OK] step_basic.json
[FIXTURES OK] 3 passed
[SMOKE OK]
```

## Where to Go Next

- **[Getting Started](getting-started.md)**: Install Docker and run your first validation
- **[Architecture](architecture.md)**: Understand the deterministic seam pattern
- **[Tooling](tooling.md)**: Command reference and workflow tips
- **[Project Structure](project-structure.md)**: Directory layout and conventions
- **[Rust + GDExtension Guide](rust-gdext.md)**: Optional Rust acceleration

## Key Concepts

### The CoreAPI Seam
All game logic flows through a single function:
```gdscript
var next_state = CoreAPI.step(current_state, {"delta": 1})
```

This enables:
- **Fixture testing**: JSON files define input → expected output
- **Deterministic replays**: Same inputs = same outputs
- **Rust migration**: Swap implementation behind the seam
