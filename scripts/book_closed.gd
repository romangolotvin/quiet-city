extends Control

const COVER := Color(0.42, 0.16, 0.14)
const SPINE := Color(0.28, 0.1, 0.09)
const PAGE := Color(0.93, 0.87, 0.74)
const EDGE := Color(0.72, 0.52, 0.32)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, COVER, true)
	draw_rect(Rect2(0.0, 0.0, maxf(size.x * 0.14, 8.0), size.y), SPINE, true)
	var page := Rect2(size.x * 0.22, size.y * 0.1, size.x * 0.68, size.y * 0.8)
	draw_rect(page, PAGE, true)
	draw_line(Vector2(size.x * 0.22, size.y * 0.1), Vector2(size.x * 0.9, size.y * 0.1), EDGE, 2.0)
	var ribbon := PackedVector2Array([
		Vector2(size.x * 0.72, 0.0),
		Vector2(size.x * 0.86, 0.0),
		Vector2(size.x * 0.79, size.y * 0.28)
	])
	draw_colored_polygon(ribbon, Color(0.78, 0.22, 0.22))
