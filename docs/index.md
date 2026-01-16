# Godot 4 + Rust GDExtension Template

Welcome! This template is built for fast iteration with AI or human collaborators by putting most logic in Rust and keeping the Godot integration thin and stable.

## What You Get

- ✅ **Godot 4 starter project** in `godot/` with a headless smoke test
- ✅ **Rust workspace** in `rust/` with a pure `core` crate and a `gdext_bridge` crate
- ✅ **Automation-first commands** (`make ci` runs fmt/lint/tests/build/smoke)
- ✅ **Beginner docs** for both Godot and GDExtension workflows

## Quick Start

1. Install Rust + Godot 4.
2. Run the extension build + smoke test:
   ```bash
   make build-ext
   make smoke
   ```
3. Run the core tests:
   ```bash
   make test
   ```

## Where to Go Next

- **Getting Started**: install tools and run the project.
- **Rust + GDExtension Guide**: architecture and workflow.
- **Tooling & Exports**: tests and formatter/linter setup.
