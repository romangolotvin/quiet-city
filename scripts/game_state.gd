extends Node

var case_id := "lost_ball"
var ending_ok := false
var ending_suspect_id := ""

## Открытый квартал
var active_case_id := ""
var caught_event_ids: Array[String] = []
var closed_case_ids: Array[String] = []

const SAVE_PATH := "user://progress.cfg"
## Сколько любых пойманных волн достаточно, чтобы открыть голосование.
const VOTE_READY_COUNT := 3


func _ready() -> void:
	load_progress()


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
	save_progress()


func clear_active_case() -> void:
	active_case_id = ""
	caught_event_ids.clear()
	save_progress()


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
	save_progress()
	return true


func caught_count() -> int:
	return caught_event_ids.size()


func case_event_count() -> int:
	return current_case().get("events", []).size()


func is_case_ready() -> bool:
	return has_active_case() and caught_count() >= VOTE_READY_COUNT


func start_ending(ok: bool, suspect_id: String) -> void:
	ending_ok = ok
	ending_suspect_id = suspect_id
	if ok and not active_case_id.is_empty():
		mark_case_closed(active_case_id)
	elif not ok:
		clear_active_case()
	else:
		save_progress()


func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "active_case_id", active_case_id)
	cfg.set_value("progress", "case_id", case_id)
	cfg.set_value("progress", "caught", ",".join(caught_event_ids))
	cfg.set_value("progress", "closed", ",".join(closed_case_ids))
	cfg.save(SAVE_PATH)


func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	active_case_id = str(cfg.get_value("progress", "active_case_id", ""))
	case_id = str(cfg.get_value("progress", "case_id", "lost_ball"))
	caught_event_ids.clear()
	closed_case_ids.clear()
	var caught_raw := str(cfg.get_value("progress", "caught", ""))
	if not caught_raw.is_empty():
		for part in caught_raw.split(",", false):
			caught_event_ids.append(str(part))
	var closed_raw := str(cfg.get_value("progress", "closed", ""))
	if not closed_raw.is_empty():
		for part in closed_raw.split(",", false):
			closed_case_ids.append(str(part))
