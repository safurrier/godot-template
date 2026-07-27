# res://adapters/input_adapter.gd
# Converts Godot Input singleton to typed GameInput.
# This is the boundary between Godot's input system and the deterministic core.
class_name InputAdapter
extends RefCounted

# Action mappings (customize per project)
const ACTION_MOVE_LEFT := "move_left"
const ACTION_MOVE_RIGHT := "move_right"
const ACTION_MOVE_UP := "move_up"
const ACTION_MOVE_DOWN := "move_down"
const ACTION_JUMP := "jump"
const ACTION_ATTACK := "attack"


static func read_input() -> GameInput:
	var inp := GameInput.new()
	inp.delta = 1  # Fixed tick

	# Example: read movement input
	# Uncomment and customize as needed:
	# var move_x := Input.get_axis(ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT)
	# var move_y := Input.get_axis(ACTION_MOVE_UP, ACTION_MOVE_DOWN)
	# inp.move_x = move_x
	# inp.move_y = move_y
	# inp.jump_pressed = Input.is_action_just_pressed(ACTION_JUMP)
	# inp.attack_pressed = Input.is_action_just_pressed(ACTION_ATTACK)

	return inp


# For replay: create input from recorded dictionary
static func from_replay(data: Dictionary) -> GameInput:
	return GameInput.from_dict(data)


# For recording: convert input to dictionary for replay log
static func to_replay(inp: GameInput) -> Dictionary:
	return inp.to_dict()
