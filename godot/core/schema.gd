# res://core/schema.gd
# Helpers for validation, JSON canonicalization, and stable ordering.
# Ensures deterministic comparisons for fixture testing.
class_name Schema

# Normalize a value to handle JSON float/int ambiguity.
# JSON parses all numbers as floats, so we convert floats that are whole numbers to int.
static func normalize_value(val):
	if val is float and val == int(val):
		return int(val)
	if val is Dictionary:
		return normalize_dict(val)
	if val is Array:
		var result := []
		for item in val:
			result.append(normalize_value(item))
		return result
	return val

# Normalize all values in a dictionary recursively.
static func normalize_dict(d: Dictionary) -> Dictionary:
	var result := {}
	for key in d:
		result[key] = normalize_value(d[key])
	return result

# Convert dictionary to canonical JSON for comparison.
# Ensures stable ordering for equality checks.
static func to_canonical_json(data: Dictionary) -> String:
	return JSON.stringify(normalize_dict(data), "", false, true)

# Deep equality check for dictionaries using canonical JSON.
static func dict_equals(a: Dictionary, b: Dictionary) -> bool:
	return to_canonical_json(a) == to_canonical_json(b)

# Validate that state has all required keys.
# @param state: Dictionary to validate
# @param required_keys: Array of key names that must exist
# @returns: true if all keys present
static func validate_state(state: Dictionary, required_keys: Array) -> bool:
	for key in required_keys:
		if not state.has(key):
			return false
	return true

# Get value with default, ensuring type safety.
static func get_int(d: Dictionary, key: String, default: int = 0) -> int:
	var val = d.get(key, default)
	return int(val) if val != null else default

static func get_float(d: Dictionary, key: String, default: float = 0.0) -> float:
	var val = d.get(key, default)
	return float(val) if val != null else default

static func get_string(d: Dictionary, key: String, default: String = "") -> String:
	var val = d.get(key, default)
	return str(val) if val != null else default

# Create a default state with common fields.
static func default_state() -> Dictionary:
	return {
		"tick": 0,
		"seed": 0,
	}
