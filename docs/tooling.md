# Tooling & Automation

This page covers recommended tools and workflows for Godot + Rust development.

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

## GDExtension Build + Smoke Test

The Makefile provides a single command surface:
```bash
make fmt
make lint
make test
make build-ext
make smoke
make ci
```

## Recommended Plugins

- **GDUnit4** or **GUT** for automated tests.
- **Dialogic** for narrative-heavy projects.
- **Godot-Redux** or custom input remapping addons for accessibility.

Keep plugins in `godot/addons/` and commit the addon source to version control.

### Installing GUT (Godot Unit Test)

1. Open **AssetLib** inside the Godot editor.
2. Search for **GUT** and click **Download**.
3. Install it to `godot/addons/`.
4. Enable it in **Project Settings → Plugins**.

### Installing GDUnit4

1. Open **AssetLib** inside the Godot editor.
2. Search for **GDUnit4** and click **Download**.
3. Install it to `godot/addons/`.
4. Enable it in **Project Settings → Plugins**.

## GDScript Formatting & Linting

Suggested tools:
- **gdformat** (formatter)
- **gdlint** (lint rules)

Example commands:
```bash
gdformat godot/scripts
gdlint godot/scripts
```

### Install gdformat / gdlint

```bash
pip install godot-gdscript-toolkit
```

## Headless Smoke Test

Godot headless mode is used for CI:
```bash
godot --headless --path godot --script res://scripts/smoke_test.gd
```

## Build Checklist

- ✅ Rust fmt + clippy pass
- ✅ `cargo test -p core` passes
- ✅ Extension builds and copies into `godot/addons/my_ext/bin/`
- ✅ Headless smoke test passes
