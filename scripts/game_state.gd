extends Node

var case_id := "lost_ball"


func current_case() -> Dictionary:
	return CaseCatalog.by_id(case_id)
