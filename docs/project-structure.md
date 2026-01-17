# Project Structure

This template uses **GDScript-first gameplay** with **optional Rust acceleration**.

## Recommended Layout

```
repo/
├── godot/                        # Godot project root
│   ├── project.godot              # Project settings
│   ├── core/                      # Deterministic seam (GDScript)
│   │   ├── core_api.gd            # step(), decide(), generate()
│   │   ├── schema.gd              # JSON normalization helpers
│   │   └── sim_clock.gd           # Batch simulation driver
│   ├── scenes/                    # Scene files (.tscn)
│   ├── scripts/                   # GDScript files (.gd)
│   │   ├── Main.gd                # Game script (uses CoreAPI)
│   │   ├── smoke_test.gd          # Headless smoke test
│   │   └── run_fixtures.gd        # Fixture test runner
│   ├── tests/
│   │   └── fixtures/              # Golden test JSON files
│   │       └── step_basic.json
│   └── addons/
│       └── my_ext/                # GDExtension (optional)
│           ├── my_ext.gdextension
│           └── bin/linux/debug/libmy_ext.so
├── rust/                          # Optional Rust acceleration
│   ├── Cargo.toml
│   ├── core/                      # Pure Rust logic + tests
│   └── gdext_bridge/              # Thin GDExtension bridge
├── docker/
│   ├── Dockerfile                 # Dev container with all tools
│   └── docker-compose.yml
├── docs/
└── README.md
```

## Key Ideas

### GDScript-First with Deterministic Seams
- **`godot/core/`**: All game logic flows through `CoreAPI.step(state, input)`
- **Pure-data in/out**: Dictionaries only, no Node references, no side effects
- **Fixture testing**: JSON files define input → expected output

### Optional Rust Acceleration
- **Core**: deterministic logic, easy to test with `cargo test`
- **Bridge**: minimal marshaling between Godot and Rust
- **Migration path**: Swap GDScript implementation for Rust behind the seam

### Keep Scripts Close to Scenes
```
scenes/player/Player.tscn
scripts/player/Player.gd
```

### GDExtension Files Are Part of the Build Contract
Treat the `.gdextension` file and the `addons/my_ext/bin/` layout as critical build artifacts.
