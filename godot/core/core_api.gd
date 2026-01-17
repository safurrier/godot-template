# res://core/core_api.gd
# The deterministic seam for game logic.
# All methods are pure-data in/out - no Node refs, no side effects.
# This enables fixture-based testing and future Rust migration.
#
# Typed Resources (GameState, GameInput) are the single source of truth.
# The step_dict() adapter provides JSON interop for fixture tests.
class_name CoreAPI

# Feature flag for later Rust refactor
const USE_RUST_SETTING := "core/use_rust"


static func use_rust() -> bool:
	return ProjectSettings.get_setting(USE_RUST_SETTING, false)


# Primary typed API for game code.
# @param state: Current game state as GameState Resource
# @param inp: Input for this tick as GameInput Resource
# @returns: Next state as new GameState Resource
static func step(state: GameState, inp: GameInput) -> GameState:
	var next := state.duplicate_state()
	next.tick += inp.delta
	return next


# Dictionary adapter for fixture tests and JSON interop.
# @param state: Current game state (Dictionary with primitives only)
# @param inp: Input for this tick (Dictionary with primitives only)
# @returns: Next state (new Dictionary, original unchanged)
static func step_dict(state: Dictionary, inp: Dictionary) -> Dictionary:
	var typed_state := GameState.from_dict(state)
	var typed_input := GameInput.from_dict(inp)
	var result := step(typed_state, typed_input)
	return result.to_dict()


# AI decision-making seam.
# @param state: Current game state
# @returns: Decision dictionary (action to take)
static func decide(state: Dictionary) -> Dictionary:
	# v1 stub: later AI logic lives here
	return {"action": "noop"}


# Procedural generation seam.
# @param seed_val: RNG seed for reproducibility
# @param params: Generation parameters
# @returns: Generated content dictionary
static func generate(seed_val: int, params: Dictionary) -> Dictionary:
	# v1 stub: procedural generation seam
	return {"seed": seed_val, "params": params}
