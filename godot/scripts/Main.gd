extends Node2D

const CoreAPIScript = preload("res://core/core_api.gd")

# Game state - uses CoreAPI deterministic seam
var state := {"tick": 0, "seed_val": 0}

func _ready() -> void:
	print("Godot starter pack loaded.")
	print("Initial state: ", state)

func _process(_delta: float) -> void:
	# Step the simulation each frame using CoreAPI
	state = CoreAPIScript.step_dict(state, {"delta": 1})

	# Debug output every 60 ticks (~1 second at 60fps)
	if state["tick"] % 60 == 0:
		print("Tick: ", state["tick"])
