# Getting Started (Godot + Rust)

This guide assumes you are new to Godot and GDExtension. We'll install tools, build the Rust extension, and run a headless smoke test.

## 1) Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

rustup default stable
rustup component add clippy rustfmt
```

## 2) Install Godot 4

Download Godot 4.x and ensure it is on your PATH as `godot`:
```bash
godot --version
```

## 3) Build the Extension

```bash
make build-ext
make copy-ext
```

This builds the `gdext_bridge` crate and copies the shared library into:
```
godot/addons/my_ext/bin/linux/debug/libmy_ext.so
```

## 4) Run the Smoke Test (Headless)

```bash
make smoke
```

Expected output:
```
[SMOKE OK]
```

## 5) Run Core Tests

```bash
make test
```

## Next Steps

- Read **Rust + GDExtension Guide** for architecture and best practices.
- Review **Tooling & Exports** to install test frameworks and linters.
