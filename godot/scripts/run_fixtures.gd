# res://scripts/run_fixtures.gd
# Headless fixture runner for CI validation.
# Runs all JSON fixtures in tests/fixtures/ and exits with appropriate code.
extends SceneTree

# Preload core modules (needed for headless execution)
const CoreAPIScript = preload("res://core/core_api.gd")
const SchemaScript = preload("res://core/schema.gd")
const GameStateScript = preload("res://core/resources/game_state.gd")
const GameInputScript = preload("res://core/resources/game_input.gd")


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
	var expected: Dictionary = parsed.get("expected_state", {})

	var got := CoreAPIScript.step_dict(initial_state, inp)

	# Deep equality check using Schema helper
	if not SchemaScript.dict_equals(got, expected):
		push_error("[FIXTURE FAIL] %s" % path)
		push_error("  expected: %s" % str(expected))
		push_error("  got:      %s" % str(got))
		return false

	# Verify Resource serialization round-trips correctly (dict -> Resource -> dict)
	var state_roundtrip = GameStateScript.from_dict(got).to_dict()
	if not SchemaScript.dict_equals(got, state_roundtrip):
		push_error("[FIXTURE FAIL] GameState round-trip mismatch: %s" % path)
		push_error("  original:   %s" % str(got))
		push_error("  roundtrip:  %s" % str(state_roundtrip))
		return false

	print("[FIXTURE OK] %s" % path.get_file())
	return true
