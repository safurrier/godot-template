# res://core/resources/game_event.gd
# Deterministic events emitted by the simulation core.
# Events are pure data - no Node refs, no side effects.
# Maps to Rust enum GameEvent for future migration.
class_name GameEvent
extends RefCounted

enum Type {
	TICK_ADVANCED,
	DAMAGE_APPLIED,
	ENTITY_SPAWNED,
	ENTITY_DESTROYED,
	SFX_REQUESTED,
	VFX_REQUESTED,
	UI_MESSAGE,
}

var type: Type = Type.TICK_ADVANCED
var payload: Dictionary = {}


static func create(event_type: Type, event_payload: Dictionary = {}) -> GameEvent:
	var event := GameEvent.new()
	event.type = event_type
	event.payload = event_payload
	return event


static func from_dict(data: Dictionary) -> GameEvent:
	var event := GameEvent.new()
	var type_str: String = data.get("type", "TICK_ADVANCED")
	# Convert string to enum value
	for i in Type.keys().size():
		if Type.keys()[i] == type_str:
			event.type = i as Type
			break
	event.payload = data.get("payload", {})
	return event


func to_dict() -> Dictionary:
	return {
		"type": Type.keys()[type],
		"payload": payload
	}


# Factory methods for common events
static func tick_advanced(old_tick: int, new_tick: int) -> GameEvent:
	return create(Type.TICK_ADVANCED, {"old_tick": old_tick, "new_tick": new_tick})


static func damage_applied(entity_id: int, amount: int, new_health: int) -> GameEvent:
	return create(Type.DAMAGE_APPLIED, {
		"entity_id": entity_id,
		"amount": amount,
		"new_health": new_health
	})


static func entity_spawned(entity_id: int, entity_type: String, x: float, y: float) -> GameEvent:
	return create(Type.ENTITY_SPAWNED, {
		"entity_id": entity_id,
		"entity_type": entity_type,
		"x": x,
		"y": y
	})


static func entity_destroyed(entity_id: int) -> GameEvent:
	return create(Type.ENTITY_DESTROYED, {"entity_id": entity_id})


static func sfx_requested(key: String) -> GameEvent:
	return create(Type.SFX_REQUESTED, {"key": key})


static func vfx_requested(key: String, x: float, y: float) -> GameEvent:
	return create(Type.VFX_REQUESTED, {"key": key, "x": x, "y": y})


static func ui_message(text_key: String, params: Dictionary = {}) -> GameEvent:
	return create(Type.UI_MESSAGE, {"text_key": text_key, "params": params})
