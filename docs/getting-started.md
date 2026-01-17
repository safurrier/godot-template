# Getting Started

This guide covers two paths: **Docker (recommended)** for a zero-setup experience, or **local installation** if you prefer native tools.

## Option A: Docker Dev Environment (Recommended)

No local tool installation required. Just Docker.

### 1) Install Docker

- **macOS**: Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [Colima](https://github.com/abiosoft/colima)
- **Linux**: `apt install docker.io docker-compose` or equivalent
- **Windows**: Install Docker Desktop with WSL2

### 2) Validate Everything Works

```bash
make dev-validate
```

This builds the container and runs the full CI suite. Expected output:
```
=== Rust === rustc 1.92.0 ...
=== Godot === 4.5.1.stable
[SMOKE OK]
Dev environment fully validated
```

### 3) Daily Workflow

```bash
# Full CI (Rust + GDScript)
make dev-ci

# Just GDScript fixture tests
make dev-fixtures

# Interactive shell for debugging
make dev-shell
```

You're done! Skip to [Next Steps](#next-steps).

---

## Option B: Local Installation

If you prefer native tools over Docker.

### 1) Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

rustup default stable
rustup component add clippy rustfmt
```

### 2) Install Godot 4

Download [Godot 4.5+](https://godotengine.org/download/) and add to PATH:
```bash
godot --version
# Should output: 4.5.x.stable
```

### 3) Validate

```bash
make ci
```

Expected output:
```
test tests::ping_formats ... ok
[SMOKE OK]
```

---

## Next Steps

### Learn the Architecture
Read [Architecture: Deterministic Seams](architecture.md) to understand the `CoreAPI.step()` pattern.

### Add Game Logic
1. Edit `godot/core/core_api.gd`
2. Add a fixture test in `godot/tests/fixtures/`
3. Run `make dev-fixtures`

### Explore the Codebase
```
godot/core/          # GDScript game logic seam
godot/tests/fixtures/# JSON fixture tests
rust/core/           # Optional Rust acceleration
```

### Common Commands

| Command | Description |
|---------|-------------|
| `make dev-ci` | Full CI in Docker |
| `make dev-fixtures` | GDScript fixture tests |
| `make dev-shell` | Interactive debugging |

See [Tooling & Automation](tooling.md) for the complete command reference.
