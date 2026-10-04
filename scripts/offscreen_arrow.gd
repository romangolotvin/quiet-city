extends Control

var target: Node2D = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(64, 64)
	pivot_offset = size * 0.5
	visible = false


func set_target(node: Node2D) -> void:
	target = node


func clear_target() -> void:
	target = null
	visible = false


func _process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		visible = false
		return

	var vp := get_viewport_rect().size
	var screen := _world_to_screen(target.global_position, vp)
	var m := UiFit.margins(get_viewport())
	var margin := 56.0
	var bounds := Rect2(
		Vector2(m.position.x + margin, m.position.y + margin),
		Vector2(m.size.x - margin * 2.0, m.size.y - margin * 2.0)
	)
	if bounds.has_point(screen):
		visible = false
		return

	var center := vp * 0.5
	var dir := screen - center
	if dir.length_squared() < 1.0:
		visible = false
		return
	dir = dir.normalized()
	var edge := _edge_point(center, dir, bounds)
	position = edge - pivot_offset
	rotation = dir.angle()
	visible = true
	queue_redraw()


func _world_to_screen(world: Vector2, vp: Vector2) -> Vector2:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return world
	return (world - cam.get_screen_center_position()) * cam.zoom + vp * 0.5


func _edge_point(origin: Vector2, dir: Vector2, bounds: Rect2) -> Vector2:
	var t := 100000.0
	if absf(dir.x) > 0.0001:
		var limit_x := bounds.position.x if dir.x < 0.0 else bounds.end.x
		t = minf(t, (limit_x - origin.x) / dir.x)
	if absf(dir.y) > 0.0001:
		var limit_y := bounds.position.y if dir.y < 0.0 else bounds.end.y
		t = minf(t, (limit_y - origin.y) / dir.y)
	return origin + dir * maxf(t, 0.0)


func _draw() -> void:
	var c := pivot_offset
	draw_circle(c, 24.0, Color(1.0, 0.86, 0.18))
	draw_arc(c, 24.0, 0.0, TAU, 28, Color(0.2, 0.12, 0.06), 3.0, true)
	var tip := c + Vector2(16, 0)
	var left := c + Vector2(-13, -13)
	var right := c + Vector2(-13, 13)
	draw_colored_polygon(PackedVector2Array([tip, left, right]), Color(0.18, 0.1, 0.06))
