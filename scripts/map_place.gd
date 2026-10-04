class_name MapPlace
extends Node2D

var place_id := ""
var place_name := ""
var idle_text := ""
var hit_radius := 84.0


func setup(id: String) -> void:
	var data := MapLayout.place(id)
	place_id = id
	place_name = str(data["name"])
	idle_text = str(data["idle"])
	position = data["pos"]
	queue_redraw()


func contains(world_pos: Vector2) -> bool:
	return global_position.distance_to(world_pos) <= hit_radius


func _draw() -> void:
	draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 28, Color(0.15, 0.1, 0.08, 0.85), 3.0, true)
	draw_circle(Vector2.ZERO, 5.0, Color(0.15, 0.1, 0.08, 0.9))
	var font := ThemeDB.fallback_font
	var text_width := font.get_string_size(place_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	draw_string(font, Vector2(-text_width * 0.5, 54), place_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.15, 0.1, 0.08))
