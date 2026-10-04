extends Node

var case_id := "lost_ball"
var ending_ok := false
var ending_suspect_id := ""


func current_case() -> Dictionary:
	return CaseCatalog.by_id(case_id)


func start_ending(ok: bool, suspect_id: String) -> void:
	ending_ok = ok
	ending_suspect_id = suspect_id
