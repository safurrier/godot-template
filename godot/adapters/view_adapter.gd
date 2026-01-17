# res://adapters/view_adapter.gd
# Applies GameState to Godot Nodes for rendering.
# This is the boundary between deterministic state and visual presentation.
class_name ViewAdapter
extends RefCounted


# Apply state to a scene root - override per project
static func apply(state: GameState, root: Node) -> void:
	# Example: find and update game objects
	# var player = root.get_node_or_null("Player")
	# if player:
	#     player.position.x = state.player_x
	#     player.position.y = state.player_y
	#
	# for entity_id in state.entities:
	#     var entity_node = root.get_node_or_null("Entities/%d" % entity_id)
	#     if entity_node:
	#         var entity_data = state.entities[entity_id]
	#         entity_node.position = Vector2(entity_data.x, entity_data.y)
	pass


# Interpolate between two states for smooth rendering
# t is 0.0 to 1.0 (fraction of tick elapsed)
static func interpolate(prev_state: GameState, next_state: GameState, t: float, root: Node) -> void:
	# Example: smooth movement between ticks
	# var player = root.get_node_or_null("Player")
	# if player:
	#     player.position.x = lerp(prev_state.player_x, next_state.player_x, t)
	#     player.position.y = lerp(prev_state.player_y, next_state.player_y, t)
	pass


# Debug helper: visualize state for development
static func debug_overlay(state: GameState, root: Node) -> void:
	# Example: update a debug label with state info
	# var debug_label = root.get_node_or_null("UI/DebugLabel")
	# if debug_label:
	#     debug_label.text = "Tick: %d\nSeed: %d" % [state.tick, state.seed_val]
	pass
