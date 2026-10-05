extends Node2D

## Житель квартала, у которого можно взять дело.

var npc_id := ""
var case_id := ""
var display_name := ""
var look := "man"
var talk_radius := 78.0


func setup(data: Dictionary) -> void:
	npc_id = str(data.get("id", ""))
	case_id = str(data.get("case_id", ""))
	display_name = str(data.get("name", "Житель"))
	look = str(data.get("look", "man"))
	position = data.get("pos", Vector2.ZERO)
	queue_redraw()


func can_talk() -> bool:
	return not case_id.is_empty() and not GameState.is_case_closed(case_id)


func contains(world_pos: Vector2) -> bool:
	return global_position.distance_to(world_pos) <= talk_radius


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var closed := GameState.is_case_closed(case_id)
	match look:
		"kids":
			_draw_kid(Vector2(-14, 0), Color(0.35, 0.55, 0.4))
			_draw_kid(Vector2(16, 4), Color(0.5, 0.4, 0.55))
		"girl":
			_draw_person(Color(0.55, 0.35, 0.42), true)
		"baker":
			_draw_person(Color(0.85, 0.82, 0.75), false)
			draw_colored_polygon(PackedVector2Array([
				Vector2(-12, -40), Vector2(12, -40), Vector2(9, -56), Vector2(-9, -56)
			]), Color(0.95, 0.95, 0.92))
		_:
			_draw_person(Color(0.3, 0.34, 0.42), false)
	if can_talk() and GameState.active_case_id != case_id:
		var bob := sin(Time.get_ticks_msec() * 0.008) * 3.0
		draw_circle(Vector2(0, -58 + bob), 7.0, Color(0.98, 0.82, 0.28))
		draw_circle(Vector2(0, -58 + bob), 7.0, Color(0.2, 0.15, 0.1), false, 2.0)
	elif closed:
		draw_circle(Vector2(0, -56), 6.0, Color(0.45, 0.8, 0.45))
	var font := ThemeDB.fallback_font
	var w := font.get_string_size(display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	draw_string(font, Vector2(-w * 0.5, 36), display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.15, 0.1, 0.08))


func _draw_person(clothes: Color, girl: bool) -> void:
	var skin := Color(0.86, 0.72, 0.58)
	draw_circle(Vector2(0, -22), 12.0, skin)
	if girl:
		draw_circle(Vector2(-8, -26), 7.0, Color(0.35, 0.2, 0.14))
		draw_circle(Vector2(8, -26), 7.0, Color(0.35, 0.2, 0.14))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-16, -10), Vector2(16, -10), Vector2(12, 18), Vector2(-12, 18)
	]), clothes)


func _draw_kid(offset: Vector2, shirt: Color) -> void:
	draw_circle(offset + Vector2(0, -14), 9.0, Color(0.86, 0.72, 0.58))
	draw_rect(Rect2(offset + Vector2(-9, -6), Vector2(18, 20)), shirt)
