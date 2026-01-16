# Godot 4 + Rust GDExtension Template

An AI-friendly Godot 4 starter template that keeps 90% of gameplay logic in a pure Rust core crate, with a thin GDExtension bridge exposed to Godot. It ships with automation for fmt/lint/tests and a headless Godot smoke test.

## Why This Template

- **Fast iteration**: most code lives in `rust/core`, tested with `cargo test`.
- **Thin bridge**: `rust/gdext_bridge` only marshals data between Godot and core logic.
- **Automation-first**: one command (`make ci`) runs fmt + clippy + tests + headless smoke.
- **Beginner docs**: Godot onboarding and a Rust + GDExtension guide.

## Quickstart

### 1) Install prerequisites

- **Rust** (stable) with `clippy` + `rustfmt`
- **Godot 4.x** on your PATH as `godot`

### 2) Build the extension and run a smoke test

```bash
make build-ext
make smoke
```

You should see `[SMOKE OK]` in the output.

### 3) Run the core unit tests

```bash
make test
```

## Project Layout

```
repo/
├── godot/                      # Godot project root
│   ├── project.godot
│   ├── addons/
│   │   └── my_ext/
│   │       ├── my_ext.gdextension
│   │       └── bin/
│   │           └── linux/debug/libmy_ext.so
│   └── scripts/
│       └── smoke_test.gd
├── rust/                       # Rust workspace
│   ├── Cargo.toml
│   ├── core/                   # Pure Rust logic (tests live here)
│   └── gdext_bridge/            # Thin GDExtension bridge
├── docs/
└── README.md
```

## Commands

```bash
make fmt        # cargo fmt --all
make lint       # cargo clippy --workspace --all-targets -- -D warnings
make test       # cargo test -p core
make build-ext  # build gdext_bridge
make copy-ext   # copy shared lib into godot/addons/my_ext/bin/linux/debug
make smoke      # godot --headless smoke test
make ci         # fmt + lint + test + build-ext + smoke
```

## Documentation

- **Getting Started**: install Godot + Rust, open the project, run the smoke test.
- **Rust + GDExtension**: fast-core + thin-bridge architecture details.
- **Tooling & Exports**: testing tools + formatter/linter installs.

Start with `docs/index.md`.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
