extends Control

const PAGE_LEFT := Color(0.95, 0.9, 0.8)
const PAGE_RIGHT := Color(0.93, 0.87, 0.76)
const SPINE := Color(0.32, 0.14, 0.12)
const COVER := Color(0.38, 0.15, 0.13)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0:
		return
	draw_rect(Rect2(Vector2.ZERO, size), COVER, true)
	var m := minf(size.x, size.y) * 0.06
	var mid := size.x * 0.5
	var page_h := size.y - m * 2.0
	var left := Rect2(m, m, mid - m - 6.0, page_h)
	var right := Rect2(mid + 6.0, m, size.x - mid - m - 6.0, page_h)
	draw_rect(left, PAGE_LEFT, true)
	draw_rect(right, PAGE_RIGHT, true)
	draw_rect(Rect2(mid - 7.0, m, 14.0, page_h), SPINE, true)
	draw_line(Vector2(mid, m), Vector2(mid, size.y - m), Color(0.2, 0.08, 0.07), 2.0, true)
