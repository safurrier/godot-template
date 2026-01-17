# res://scripts/Main.gd
# Main game script demonstrating the deterministic seam pattern.
# Uses typed Resources and adapters for clean separation of concerns.
extends Node2D

# Game state - uses CoreAPI deterministic seam
var state: GameState
var event_adapter: EventAdapter


func _ready() -> void:
	# Initialize typed state
	state = GameState.new()
	state.tick = 0
	state.seed_val = 0
	state.rng_state = 42  # Deterministic seed

	# Initialize event adapter
	event_adapter = EventAdapter.new()

	print("Godot starter pack loaded.")
	print("Initial state: tick=%d, seed_val=%d, rng_state=%d" % [state.tick, state.seed_val, state.rng_state])


func _process(_delta: float) -> void:
	# Read input via adapter
	var inp := InputAdapter.read_input()

	# Step the simulation using CoreAPI (returns StepResult with state + events)
	var result := CoreAPI.step(state, inp)

	# Update state
	state = result.state

	# Process events for presentation (VFX, SFX, UI)
	event_adapter.process_events(result.events, self)

	# Apply state to view (update node positions, animations, etc.)
	ViewAdapter.apply(state, self)

	# Debug output every 60 ticks (~1 second at 60fps)
	if state.tick % 60 == 0:
		print("Tick: %d" % state.tick)
