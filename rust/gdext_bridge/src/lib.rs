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
}
