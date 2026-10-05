extends Node

var case_id := "lost_ball"
var ending_ok := false
var ending_suspect_id := ""

## Открытый квартал
var active_case_id := ""
var caught_event_ids: Array[String] = []
var closed_case_ids: Array[String] = []


func current_case() -> Dictionary:
	if not active_case_id.is_empty():
		return CaseCatalog.by_id(active_case_id)
	return CaseCatalog.by_id(case_id)


func has_active_case() -> bool:
	return not active_case_id.is_empty()


func start_case(id: String) -> void:
	active_case_id = id
	case_id = id
	caught_event_ids.clear()


func clear_active_case() -> void:
	active_case_id = ""
	caught_event_ids.clear()


func is_case_closed(id: String) -> bool:
	return closed_case_ids.has(id)


func mark_case_closed(id: String) -> void:
	if not closed_case_ids.has(id):
		closed_case_ids.append(id)
	clear_active_case()


func is_event_caught(event_id: String) -> bool:
	return caught_event_ids.has(event_id)


func catch_event(event_id: String) -> bool:
	if is_event_caught(event_id):
		return false
	caught_event_ids.append(event_id)
	return true


func caught_count() -> int:
	return caught_event_ids.size()


func case_event_count() -> int:
	return current_case().get("events", []).size()


func is_case_ready() -> bool:
	return has_active_case() and caught_count() >= case_event_count()


func start_ending(ok: bool, suspect_id: String) -> void:
	ending_ok = ok
	ending_suspect_id = suspect_id
	if ok and not active_case_id.is_empty():
		mark_case_closed(active_case_id)
	elif not ok:
		clear_active_case()
