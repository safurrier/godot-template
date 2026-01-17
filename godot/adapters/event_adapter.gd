# res://adapters/event_adapter.gd
# Consumes GameEvents and triggers Godot presentation (VFX, SFX, UI).
# This is the boundary between deterministic events and audiovisual feedback.
class_name EventAdapter
extends RefCounted

# Sound effect registry (key -> AudioStream path)
var sfx_registry: Dictionary = {}

# VFX registry (key -> PackedScene path)
var vfx_registry: Dictionary = {}


func _init() -> void:
	# Register default SFX/VFX mappings
	# sfx_registry["hit"] = "res://audio/sfx/hit.wav"
	# sfx_registry["jump"] = "res://audio/sfx/jump.wav"
	# vfx_registry["explosion"] = "res://vfx/explosion.tscn"
	# vfx_registry["hit_spark"] = "res://vfx/hit_spark.tscn"
	pass


func process_events(events: Array[GameEvent], root: Node) -> void:
	for event in events:
		_handle_event(event, root)


func _handle_event(event: GameEvent, root: Node) -> void:
	match event.type:
		GameEvent.Type.TICK_ADVANCED:
			pass  # Usually no presentation needed

		GameEvent.Type.DAMAGE_APPLIED:
			_on_damage_applied(event.payload, root)

		GameEvent.Type.ENTITY_SPAWNED:
			_on_entity_spawned(event.payload, root)

		GameEvent.Type.ENTITY_DESTROYED:
			_on_entity_destroyed(event.payload, root)

		GameEvent.Type.SFX_REQUESTED:
			_play_sfx(event.payload.get("key", ""), root)

		GameEvent.Type.VFX_REQUESTED:
			_spawn_vfx(event.payload, root)

		GameEvent.Type.UI_MESSAGE:
			_show_ui_message(event.payload, root)


func _on_damage_applied(payload: Dictionary, root: Node) -> void:
	# Example: flash entity red, show damage number
	# var entity_id = payload.get("entity_id", 0)
	# var amount = payload.get("amount", 0)
	# var entity_node = root.get_node_or_null("Entities/%d" % entity_id)
	# if entity_node and entity_node.has_method("flash_damage"):
	#     entity_node.flash_damage(amount)
	pass


func _on_entity_spawned(payload: Dictionary, root: Node) -> void:
	# Example: play spawn animation or sound
	# var entity_type = payload.get("entity_type", "")
	# var x = payload.get("x", 0.0)
	# var y = payload.get("y", 0.0)
	pass


func _on_entity_destroyed(payload: Dictionary, root: Node) -> void:
	# Example: play death animation
	# var entity_id = payload.get("entity_id", 0)
	pass


func _play_sfx(key: String, root: Node) -> void:
	if not sfx_registry.has(key):
		return
	# var stream = load(sfx_registry[key])
	# var player = AudioStreamPlayer.new()
	# player.stream = stream
	# root.add_child(player)
	# player.play()
	# player.finished.connect(player.queue_free)


func _spawn_vfx(payload: Dictionary, root: Node) -> void:
	var key: String = payload.get("key", "")
	if not vfx_registry.has(key):
		return
	# var scene = load(vfx_registry[key])
	# var instance = scene.instantiate()
	# instance.position = Vector2(payload.get("x", 0), payload.get("y", 0))
	# root.add_child(instance)


func _show_ui_message(payload: Dictionary, root: Node) -> void:
	# var text_key = payload.get("text_key", "")
	# var ui = root.get_node_or_null("UI")
	# if ui and ui.has_method("show_message"):
	#     ui.show_message(text_key, payload.get("params", {}))
	pass
