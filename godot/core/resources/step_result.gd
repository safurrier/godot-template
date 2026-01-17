# res://core/resources/step_result.gd
# Return type for CoreAPI.step() - contains next state AND deterministic events.
# Events are emitted during the step and describe "what happened".
class_name StepResult
extends RefCounted

var state: GameState
var events: Array[GameEvent]


static func create(new_state: GameState, new_events: Array[GameEvent] = []) -> StepResult:
	var result := StepResult.new()
	result.state = new_state
	result.events = new_events
	return result


static func from_dict(data: Dictionary) -> StepResult:
	var result := StepResult.new()
	result.state = GameState.from_dict(data.get("state", {}))
	result.events = []
	for event_dict in data.get("events", []):
		result.events.append(GameEvent.from_dict(event_dict))
	return result


func to_dict() -> Dictionary:
	var events_array: Array[Dictionary] = []
	for event in events:
		events_array.append(event.to_dict())
	return {
		"state": state.to_dict(),
		"events": events_array
	}
