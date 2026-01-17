# res://core/resources/game_state.gd
# Typed state representation for the deterministic seam.
# Maps 1:1 to Rust struct for future migration.
class_name GameState
extends Resource

@export var tick: int = 0
@export var seed_val: int = 0
@export var rng_state: int = 0  # Deterministic RNG position


static func from_dict(data: Dictionary) -> GameState:
	var state := GameState.new()
	state.tick = int(data.get("tick", 0))
	state.seed_val = int(data.get("seed_val", 0))
	state.rng_state = int(data.get("rng_state", 0))
	return state


func to_dict() -> Dictionary:
	return {"tick": tick, "seed_val": seed_val, "rng_state": rng_state}


func duplicate_state() -> GameState:
	var copy := GameState.new()
	copy.tick = tick
	copy.seed_val = seed_val
	copy.rng_state = rng_state
	return copy


# Deterministic random number generation
# Uses LCG algorithm - simple but sufficient for game logic
# For better quality, consider PCG or xorshift
func next_random() -> float:
	rng_state = (rng_state * 1103515245 + 12345) & 0x7FFFFFFF
	return float(rng_state) / float(0x7FFFFFFF)


func next_random_int(max_value: int) -> int:
	return int(next_random() * max_value)
