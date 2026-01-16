# Godot + Rust Resources

A curated starter list for Godot 4 + GDExtension development.

## Official Godot Docs

- Godot Manual: https://docs.godotengine.org/en/stable/
- Class Reference: https://docs.godotengine.org/en/stable/classes/
- GDScript Basics: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- Input Map: https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html
- Headless/CLI: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html

## Godot + Rust (GDExtension)

- godot-rust book: https://godot-rust.github.io/book/
- godot-rust repo: https://github.com/godot-rust/gdext

## Learning Paths

- 2D Game Tutorial: https://docs.godotengine.org/en/stable/getting_started/first_2d_game/
- 3D Game Tutorial: https://docs.godotengine.org/en/stable/getting_started/first_3d_game/

## Testing & Tooling

- GUT: https://github.com/bitwes/Gut
- GDUnit4: https://github.com/MikeSchulze/gdUnit4
- gdformat / gdlint: https://github.com/Scony/godot-gdscript-toolkit
- rust-cache: https://github.com/Swatinem/rust-cache

## Quick Reference Checklist

- [ ] Core tests pass (`cargo test -p core`)
- [ ] Extension builds and copies into `godot/addons/my_ext/bin/`
- [ ] Smoke test passes headless
- [ ] CI cache enabled for Rust builds
