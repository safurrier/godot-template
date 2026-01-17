# res://core/sim_clock.gd
# Deterministic tick driver for running simulations.
# Useful for replays, testing, and AI training.
class_name SimClock

# Run multiple ticks of the simulation.
# @param initial_state: Starting state
# @param inputs: Array of input dictionaries (one per tick, or empty for defaults)
# @param ticks: Number of ticks to run
# @returns: Final state after all ticks
static func run_ticks(initial_state: Dictionary, inputs: Array, ticks: int) -> Dictionary:
	var state := initial_state.duplicate(true)
	for i in range(ticks):
		var inp: Dictionary = inputs[i] if i < inputs.size() else {}
		state = CoreAPI.step(state, inp)
	return state

# Run simulation until a condition is met.
# @param initial_state: Starting state
# @param condition: Callable that takes state and returns bool
# @param max_ticks: Safety limit
# @returns: Final state when condition met or max reached
static func run_until(initial_state: Dictionary, condition: Callable, max_ticks: int = 10000) -> Dictionary:
	var state := initial_state.duplicate(true)
	var tick := 0
	while tick < max_ticks:
		if condition.call(state):
			break
		state = CoreAPI.step(state, {})
		tick += 1
	return state
