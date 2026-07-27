# res://scripts/run_fixtures.gd
# Headless fixture runner for CI validation.
# Runs all JSON fixtures in tests/fixtures/ and exits with appropriate code.
# Supports both state and event assertions.
extends SceneTree

# Preload core modules (needed for headless execution)
const CoreAPIScript = preload("res://core/core_api.gd")
const SchemaScript = preload("res://core/schema.gd")
const GameStateScript = preload("res://core/resources/game_state.gd")
const GameInputScript = preload("res://core/resources/game_input.gd")
const GameEventScript = preload("res://core/resources/game_event.gd")
const StepResultScript = preload("res://core/resources/step_result.gd")


func _initialize():
	var failures := 0
	var passed := 0
	var dir := DirAccess.open("res://tests/fixtures")

	if dir == null:
		push_error("[FIXTURES] Directory missing: res://tests/fixtures")
		quit(2)
		return

	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if not dir.current_is_dir() and name.ends_with(".json"):
			if _run_fixture("res://tests/fixtures/%s" % name):
				passed += 1
			else:
				failures += 1
		name = dir.get_next()
	dir.list_dir_end()

	if passed == 0 and failures == 0:
		print("[FIXTURES] No fixtures found in res://tests/fixtures/")
		quit(0)
		return

	if failures > 0:
		push_error("[FIXTURES FAIL] %d passed, %d failed" % [passed, failures])
		quit(1)
	else:
		print("[FIXTURES OK] %d passed" % passed)
		quit(0)


func _run_fixture(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("[FIXTURE] Cannot open: %s" % path)
		return false

	var text := f.get_as_text()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[FIXTURE] Invalid JSON (must be object): %s" % path)
		return false

	var initial_state: Dictionary = parsed.get("initial_state", {})
	var inp: Dictionary = parsed.get("input", {})
	var expected_state: Dictionary = parsed.get("expected_state", {})
	var expected_events: Array = parsed.get("expected_events", [])

	# Run step and get full result (state + events)
	var result := CoreAPIScript.step_dict(initial_state, inp)
	var actual_state: Dictionary = result.get("state", {})
	var actual_events: Array = result.get("events", [])

	# Normalize for comparison
	actual_state = SchemaScript.normalize_dict(actual_state)
	expected_state = SchemaScript.normalize_dict(expected_state)

	# Validate state
	if not SchemaScript.dict_equals(actual_state, expected_state):
		push_error("[FIXTURE FAIL] %s" % path)
		push_error("  State mismatch:")
		push_error("    expected: %s" % str(expected_state))
		push_error("    actual:   %s" % str(actual_state))
		return false

	# Validate events (if expected_events provided)
	if expected_events.size() > 0:
		if not _events_match(actual_events, expected_events):
			push_error("[FIXTURE FAIL] %s" % path)
			push_error("  Events mismatch:")
			push_error("    expected: %s" % str(expected_events))
			push_error("    actual:   %s" % str(actual_events))
			return false

	# Verify Resource serialization round-trips correctly (dict -> Resource -> dict)
	var state_roundtrip = GameStateScript.from_dict(actual_state).to_dict()
	state_roundtrip = SchemaScript.normalize_dict(state_roundtrip)
	if not SchemaScript.dict_equals(actual_state, state_roundtrip):
		push_error("[FIXTURE FAIL] GameState round-trip mismatch: %s" % path)
		push_error("  original:   %s" % str(actual_state))
		push_error("  roundtrip:  %s" % str(state_roundtrip))
		return false

	print("[FIXTURE OK] %s" % path.get_file())
	return true


func _events_match(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false

	for i in range(expected.size()):
		var exp_event: Dictionary = expected[i]
		var act_event: Dictionary = actual[i]

		# Check type matches
		if exp_event.get("type") != act_event.get("type"):
			return false

		# Check payload (if specified in expected)
		var exp_payload: Dictionary = exp_event.get("payload", {})
		var act_payload: Dictionary = act_event.get("payload", {})

		for key in exp_payload.keys():
			if not act_payload.has(key):
				return false
			# Normalize for comparison
			var exp_val = SchemaScript.normalize_value(exp_payload[key])
			var act_val = SchemaScript.normalize_value(act_payload[key])
			if exp_val != act_val:
				return false

	return true
