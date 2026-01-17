# res://core/core_api.gd
# The deterministic seam for game logic.
# All methods are pure-data in/out - no Node refs, no side effects.
# This enables fixture-based testing and future Rust migration.
class_name CoreAPI

# Feature flag for later Rust refactor
const USE_RUST_SETTING := "core/use_rust"

static func use_rust() -> bool:
	return ProjectSettings.get_setting(USE_RUST_SETTING, false)

# The core step function: pure-data in/out.
# @param state: Current game state (Dictionary with primitives only)
# @param inp: Input for this tick (Dictionary with primitives only)
# @returns: Next state (new Dictionary, original unchanged)
static func step(state: Dictionary, inp: Dictionary) -> Dictionary:
	# v1: GDScript implementation
	# Keep this deterministic and side-effect-free.
	var next := state.duplicate(true)

	# Example: a simple counter-based sim.
	var delta := int(inp.get("delta", 1))
	next["tick"] = int(next.get("tick", 0)) + delta

	return next

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
