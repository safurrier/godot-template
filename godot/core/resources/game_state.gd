# res://core/resources/game_state.gd
# Typed state representation for the deterministic seam.
# Maps 1:1 to Rust struct for future migration.
class_name GameState
extends Resource

@export var tick: int = 0
@export var seed_val: int = 0


static func from_dict(data: Dictionary) -> GameState:
	var state := GameState.new()
	state.tick = int(data.get("tick", 0))
	state.seed_val = int(data.get("seed_val", 0))
	return state


func to_dict() -> Dictionary:
	return {"tick": tick, "seed_val": seed_val}


func duplicate_state() -> GameState:
	var copy := GameState.new()
	copy.tick = tick
	copy.seed_val = seed_val
	return copy
