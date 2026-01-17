extends SceneTree

func _initialize() -> void:
    var ok := true
    var err := ""

    var rust_smoke = ClassDB.instantiate("RustSmoke")
    if rust_smoke == null:
        ok = false
        err = "Failed to instantiate RustSmoke (extension not loaded or class not registered)."
    else:
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

    if not ok:
        push_error("[SMOKE FAIL] " + err)
        quit(1)
    else:
        print("[SMOKE OK]")
        quit(0)
