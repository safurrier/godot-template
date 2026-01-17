# res://core/resources/game_input.gd
# Typed input representation for the deterministic seam.
# Maps 1:1 to Rust struct for future migration.
class_name GameInput
extends Resource

@export var delta: int = 1


static func from_dict(data: Dictionary) -> GameInput:
	var inp := GameInput.new()
	inp.delta = int(data.get("delta", 1))
	return inp


func to_dict() -> Dictionary:
	return {"delta": delta}
