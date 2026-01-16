# Starter Pack Tutorial: Your First Playable Scene

This tutorial builds a tiny 2D scene with player movement and a camera. It assumes zero Godot experience.

## Goals

- Add a player character
- Move with WASD / arrow keys
- Keep the camera centered

## 1. Create a Player Scene

1. In the FileSystem panel, create a new folder: `godot/scenes/player/`.
2. Click **Scene → New Scene**.
3. Add a **CharacterBody2D** node and name it `Player`.
4. Add a child **Sprite2D** (for visuals) and **CollisionShape2D** (for collisions).
5. Save the scene as `godot/scenes/player/Player.tscn`.

### Add a Script

Attach a new script to the `Player` node named `Player.gd` in `godot/scripts/`:
```gdscript
extends CharacterBody2D

@export var speed: float = 300.0

func _physics_process(_delta: float) -> void:
    var input_vector = Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )

    velocity = input_vector.normalized() * speed
    move_and_slide()
```

## 2. Update the Main Scene

Open `godot/scenes/Main.tscn` and:
1. Add a **Node2D** named `World`.
2. Instance your new `Player.tscn` as a child of `World`.
3. Add a **Camera2D** as a child of `Player`.
4. Enable **Current** on the Camera2D so it becomes active.

Your scene tree should look like:
```
Main (Node2D)
└── World (Node2D)
    └── Player (CharacterBody2D)
        ├── Sprite2D
        ├── CollisionShape2D
        └── Camera2D
```

## 3. Run the Game

Press **F5** to run the project. Your player should move with the arrow keys or WASD (Godot maps both to `ui_*` actions by default).

## 4. Optional: Add a Floor

1. In `Main.tscn`, add a **StaticBody2D** with a **CollisionShape2D**.
2. Use a **RectangleShape2D** and scale it to make a floor.
3. Add a **ColorRect** or **Sprite2D** for visuals.

## 5. What You Learned

- How to create scenes and instance them
- How to attach scripts to nodes
- How to move a character with built-in input actions
- How to keep the camera centered

Next, review the **Project Structure** page to learn how to organize larger games.
