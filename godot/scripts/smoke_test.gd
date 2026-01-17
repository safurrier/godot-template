extends SceneTree

const CoreAPIScript = preload("res://core/core_api.gd")

func _initialize() -> void:
	var ok := true
	var err := ""

	# Test 1: CoreAPI.step works (GDScript seam) - now returns StepResult
	var s := {"tick": 0, "seed_val": 0, "rng_state": 0}
	var result: Dictionary = CoreAPIScript.step_dict(s, {"delta": 1})
	var state: Dictionary = result.get("state", {})
	var events: Array = result.get("events", [])
	if state.get("tick", -1) != 1:
		ok = false
		err = "CoreAPI.step state invariant failed: expected tick=1, got=%s" % str(state)
	elif events.size() != 1:
		ok = false
		err = "CoreAPI.step events invariant failed: expected 1 event, got=%d" % events.size()
	elif events[0].get("type", "") != "TICK_ADVANCED":
		ok = false
		err = "CoreAPI.step event type failed: expected TICK_ADVANCED, got=%s" % events[0].get("type", "")

	# Test 2: Main scene can be loaded
	if ok:
		var scene := load("res://scenes/Main.tscn")
		if scene == null:
			ok = false
			err = "Could not load main scene"

	# Test 3: Rust extension (optional - only if built)
	if ok:
		var rust_smoke = ClassDB.instantiate("RustSmoke")
		if rust_smoke != null:
			# Test ping
			var got = rust_smoke.ping("hi")
			if got != "hi -> pong":
				ok = false
				err = "Unexpected ping() result: %s" % [str(got)]

			# Test calculate_damage
			if ok:
				var damage = rust_smoke.calculate_damage(100, 1.5)
				if damage != 150:
					ok = false
					err = "Unexpected calculate_damage() result: %d (expected 150)" % [damage]

			# Test greet_player
			if ok:
				var greeting = rust_smoke.greet_player("Alex")
				if greeting != "Welcome to the game, Alex!":
					ok = false
					err = "Unexpected greet_player() result: %s" % [greeting]
		# Note: RustSmoke is optional - we don't fail if it's not available

	if not ok:
		push_error("[SMOKE FAIL] " + err)
		quit(1)
	else:
		print("[SMOKE OK]")
		quit(0)
