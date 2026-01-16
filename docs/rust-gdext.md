# Rust + GDExtension Guide (Fast Core, Thin Bridge)

This project follows a **fast-core + thin-bridge** architecture:

- **`rust/core`** owns deterministic gameplay logic and tests.
- **`rust/gdext_bridge`** is a minimal GDExtension surface that marshals data between Godot and the core.
- **Godot scenes/UI** remain in GDScript or minimal Rust classes.

## Architecture Principles

1. **Fast iteration loop**
   - 90% of changes land in `rust/core`.
   - `cargo test -p core` is the primary feedback loop.
2. **Thin GDExtension bridge**
   - Keep Godot-specific types in the bridge only.
   - Expose a narrow API to GDScript.
3. **Deterministic automation**
   - `make ci` runs fmt, clippy, tests, builds the extension, and runs a headless smoke test.

## GDExtension Contract

The extension is loaded by `godot/addons/my_ext/my_ext.gdextension` and expects the entry symbol:
```
entry_symbol = "gdext_rust_init"
```
The compiled library is copied into:
```
godot/addons/my_ext/bin/linux/debug/libmy_ext.so
```

## Rust Workspace Layout

```
rust/
├── Cargo.toml        # workspace members: core, gdext_bridge
├── core/             # pure Rust logic + tests
└── gdext_bridge/     # GDExtension bridge (cdylib)
```

## Smoke Test

The headless smoke test (`godot/scripts/smoke_test.gd`) verifies:

1. The extension loads.
2. `RustSmoke` is instantiable.
3. `RustSmoke.ping("hi")` returns `"hi -> pong"`.

Run it with:
```bash
make smoke
```

## Headless Caveat (Import Timing)

On CI, imports can race if the project exits too quickly. The smoke test is intentionally small but should be the **last step** in CI to ensure imports finish.

## Acceptance Checklist

- [ ] `make test` runs `cargo test -p core` quickly.
- [ ] `make smoke` passes headless without opening a window.
- [ ] `make ci` succeeds on Linux in a fresh clone.
- [ ] `.gdextension` paths match the copied artifacts.
