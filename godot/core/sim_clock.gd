# res://core/sim_clock.gd
# Deterministic tick driver for running simulations.
# Useful for replays, testing, and AI training.
class_name SimClock

# Run multiple ticks of the simulation.
# @param initial_state: Starting state
# @param inputs: Array of input dictionaries (one per tick, or empty for defaults)
# @param ticks: Number of ticks to run
# @returns: Final state after all ticks (events discarded)
static func run_ticks(initial_state: Dictionary, inputs: Array, ticks: int) -> Dictionary:
	var state := initial_state.duplicate(true)
	for i in range(ticks):
		var inp: Dictionary = inputs[i] if i < inputs.size() else {}
		var result := CoreAPI.step_dict(state, inp)
		state = result.get("state", state)
	return state


# Run multiple ticks and collect all events.
# @param initial_state: Starting state
# @param inputs: Array of input dictionaries (one per tick, or empty for defaults)
# @param ticks: Number of ticks to run
# @returns: Dictionary with "state" (final) and "events" (all events from all ticks)
static func run_ticks_with_events(initial_state: Dictionary, inputs: Array, ticks: int) -> Dictionary:
	var state := initial_state.duplicate(true)
	var all_events: Array = []
	for i in range(ticks):
		var inp: Dictionary = inputs[i] if i < inputs.size() else {}
		var result := CoreAPI.step_dict(state, inp)
		state = result.get("state", state)
		all_events.append_array(result.get("events", []))
	return {"state": state, "events": all_events}


# Run simulation until a condition is met.
# @param initial_state: Starting state
# @param condition: Callable that takes state and returns bool
# @param max_ticks: Safety limit
# @returns: Final state when condition met or max reached (events discarded)
static func run_until(initial_state: Dictionary, condition: Callable, max_ticks: int = 10000) -> Dictionary:
	var state := initial_state.duplicate(true)
	var tick := 0
	while tick < max_ticks:
		if condition.call(state):
			break
		var result := CoreAPI.step_dict(state, {})
		state = result.get("state", state)
		tick += 1
	return state
