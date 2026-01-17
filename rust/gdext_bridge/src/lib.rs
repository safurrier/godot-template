use godot::prelude::*;

/// GDExtension entrypoint tag type.
struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}

/// A tiny smoke-test class exposed to Godot.
#[derive(GodotClass)]
#[class(base = Node)]
struct RustSmoke {
    base: Base<Node>,
}

#[godot_api]
impl INode for RustSmoke {
    fn init(base: Base<Node>) -> Self {
        Self { base }
    }
}

#[godot_api]
impl RustSmoke {
    /// Callable from GDScript: RustSmoke.ping("hi") -> "hi -> pong"
    #[func]
    fn ping(&self, input: GString) -> GString {
        let out = core::ping(&input.to_string());
        out.into()
    }

    /// Calculate damage: RustSmoke.calculate_damage(100, 1.5) -> 150
    #[func]
    fn calculate_damage(&self, base_damage: i32, multiplier: f32) -> i32 {
        core::calculate_damage(base_damage, multiplier)
    }

    /// Greet a player: RustSmoke.greet_player("Alex") -> "Welcome to the game, Alex!"
    #[func]
    fn greet_player(&self, name: GString) -> GString {
        core::greet_player(&name.to_string()).into()
    }
}
