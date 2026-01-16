extends SceneTree

func _initialize() -> void:
    var ok := true
    var err := ""

    var rust_smoke = ClassDB.instantiate("RustSmoke")
    if rust_smoke == null:
        ok = false
        err = "Failed to instantiate RustSmoke (extension not loaded or class not registered)."
    else:
        var got = rust_smoke.ping("hi")
        if got != "hi -> pong":
            ok = false
            err = "Unexpected ping() result: %s" % [str(got)]

    if not ok:
        push_error("[SMOKE FAIL] " + err)
        quit(1)
    else:
        print("[SMOKE OK]")
        quit(0)
