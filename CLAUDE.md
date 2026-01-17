# CLAUDE.md - Godot + Rust GDExtension Project

This is a Godot 4 + Rust GDExtension template following the "fast core, thin bridge" architecture.

## Quick Start

### Validate Everything Works
```bash
# Using Docker (recommended - includes all tools)
make dev-validate

# Or just run CI in container
make dev-ci
```

### Local Development (requires Godot on PATH)
```bash
make ci          # Full validation: fmt + lint + test + build + smoke
make test        # Just Rust tests (fast, ~0.00s)
make smoke       # Build extension + run Godot smoke test
```

## Architecture

**90% pure Rust core** + **thin GDExtension bridge**:

- `rust/core/` - Pure Rust game logic, no Godot dependency. Fast `cargo test`.
- `rust/gdext_bridge/` - Minimal GDExtension wrapper, exposes Rust to Godot.
- `godot/` - Godot project with scenes and GDScript.

Most changes happen in `rust/core/` where iteration is fast and tests are pure Rust.

## Key Commands

| Command | Description |
|---------|-------------|
| `make ci` | Full local CI: fmt + lint + test + build-ext + smoke |
| `make test` | Run `cargo test -p core` (fast, covers game logic) |
| `make smoke` | Build extension and run Godot headless smoke test |
| `make dev-ci` | Run `make ci` inside Docker container |
| `make dev-validate` | Check tools + run full CI in container |
| `make dev-shell` | Interactive bash in container |

## Validation Loop

When making changes, run this sequence:

1. **Edit code** in `rust/core/` (most changes)
2. **Run tests**: `cd rust && cargo test -p core`
3. **Full validation**: `make dev-ci` or `make ci`

Expected output:
```
test tests::ping_formats ... ok
[SMOKE OK]
```

## File Structure

```
godot/
  project.godot                    # Godot project config
  addons/my_ext/
    my_ext.gdextension            # Extension manifest (loads .so/.dll/.dylib)
    bin/                          # Built extension binaries per platform
  scripts/
    smoke_test.gd                 # Headless smoke test script

rust/
  Cargo.toml                      # Workspace (members: core, gdext_bridge)
  core/
    src/lib.rs                    # Pure Rust game logic + tests
  gdext_bridge/
    src/lib.rs                    # GDExtension entry + Godot-exposed classes

docker/
  Dockerfile                      # Rust 1.92 + Godot 4.5.1 + Python/uv
  docker-compose.yml              # Dev container config
```

## Adding New Functionality

### Adding game logic (most common)
1. Add code to `rust/core/src/lib.rs`
2. Add unit tests in the same file
3. Run `cargo test -p core`

### Exposing to Godot
1. Add a method in `rust/gdext_bridge/src/lib.rs`
2. Use `#[func]` attribute to expose it
3. Call from GDScript via `ClassName.method_name()`

Example:
```rust
// In gdext_bridge/src/lib.rs
#[godot_api]
impl RustSmoke {
    #[func]
    fn my_new_method(&self, input: GString) -> GString {
        let result = core::my_logic(&input.to_string());
        result.into()
    }
}
```

## Docker Dev Environment

The container includes:
- Rust 1.92 + clippy + rustfmt
- Godot 4.5.1 headless (ARM64 or x86_64 auto-detected)
- Python 3.11 + uv

```bash
# Build container
docker compose -f docker/docker-compose.yml build

# Run commands in container
make dev-ci              # Run CI
make dev-shell           # Interactive shell
make dev-check-tools     # Verify all tools available
```

## CI/CD

GitHub Actions runs on every PR and push to main:
1. Rust format check
2. Clippy lint
3. Core tests
4. Build extension
5. Godot headless smoke test

See `.github/workflows/ci.yml` for details.

## Troubleshooting

### "Extension not loaded" in smoke test
- Ensure extension is built: `cd rust && cargo build -p my_ext`
- Check `.gdextension` paths match your platform

### Docker compose not found
```bash
brew install docker-compose
# Add to ~/.docker/config.json:
# "cliPluginsExtraDirs": ["/opt/homebrew/lib/docker/cli-plugins"]
```

### libfontconfig warning
This is cosmetic - Godot runs fine headless without font rendering.

## Best Practices

1. **Keep bridge thin** - Only marshal data between Godot and core
2. **Test in core** - Pure Rust tests are fast and reliable
3. **Validate often** - Run `make dev-ci` before committing
4. **Use container** - Ensures consistent environment across machines

## Plan Persistence

Plans are stored in `.ai/plans/` with the format:
```
.ai/plans/$TIMESTAMP-$description/
  Spec.md           # Requirements and design decisions
  Implementation.md # Concrete file implementations
  Todo.md           # Task checklist with phases
```

### Creating a Plan
When asked to plan a feature, create a timestamped directory:
```bash
mkdir -p .ai/plans/$(date +%Y-%m-%d)-feature-name
```

Then create `Spec.md`, `Implementation.md`, and `Todo.md` with:
- **Spec.md**: Goals, non-goals, design decisions, acceptance criteria
- **Implementation.md**: Concrete code examples and file contents
- **Todo.md**: Phased task checklist

### Resuming Work

When asked to "resume" or continue work:

1. **Check the current branch**: `git branch --show-current`
2. **Review recent commits**: `git log --oneline -5`
3. **Find matching plan**: Look in `.ai/plans/` for plans matching the branch name or recent commit descriptions
4. **Read the plan files**:
   ```bash
   ls .ai/plans/
   cat .ai/plans/$MATCHING_PLAN/Todo.md
   ```
5. **Identify incomplete tasks** from `Todo.md` (items still marked `[ ]`)
6. **Continue implementation** from where it left off

Example resume workflow:
```bash
# 1. Check context
git branch --show-current
git log --oneline -5

# 2. Find plan
ls .ai/plans/

# 3. Read plan status
cat .ai/plans/2026-01-16-gdscript-first-template/Todo.md

# 4. Continue from first incomplete task
```

### Plan Naming Convention

Use descriptive names that match branch names when possible:
- `2026-01-16-gdscript-first-template/` → branch `feat/gdscript-first-template`
- `2026-01-16-dev-environment-validation-loop/` → branch `feat/validation-loop`
