# Project Structure

This template splits the project into two top-level roots: `godot/` and `rust/`.

## Recommended Layout

```
repo/
├── godot/                       # Godot project root
│   ├── project.godot             # Project settings
│   ├── scenes/                   # Scene files (.tscn)
│   ├── scripts/                  # GDScript files (.gd)
│   └── addons/
│       └── my_ext/               # GDExtension wrapper + binaries
│           ├── my_ext.gdextension
│           └── bin/linux/debug/libmy_ext.so
├── rust/                         # Rust workspace
│   ├── Cargo.toml
│   ├── core/                     # Pure Rust logic + tests
│   └── gdext_bridge/             # Thin GDExtension bridge
├── docs/
└── README.md
```

## Key Ideas

### Fast Core, Thin Bridge
- **Core**: deterministic logic, easy to test.
- **Bridge**: minimal marshaling between Godot and Rust.

### Keep Scripts Close to Scenes
```
scenes/player/Player.tscn
scripts/player/Player.gd
```

### GDExtension Files Are Part of the Build Contract
Treat the `.gdextension` file and the `addons/my_ext/bin/` layout as critical build artifacts.
