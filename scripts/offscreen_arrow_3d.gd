extends Control

## Стрелка к цели в 3D (база / NPC с делом).

var target: Node3D = null
var _label := "→"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(72, 72)
	pivot_offset = size * 0.5
	visible = false


func set_target_3d(node: Node3D, caption: String = "") -> void:
	target = node
	_label = caption


func clear_target() -> void:
	target = null
	visible = false


func _process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		visible = false
		return
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		visible = false
		return
	var world := target.global_position + Vector3(0, 24, 0)
	if cam.is_position_behind(world):
		# Цель за камерой — стрелка всё равно к краю в сторону цели на XZ.
		pass
	var screen := cam.unproject_position(world)
	var vp := get_viewport_rect().size
	var m := UiFit.margins(get_viewport())
	var margin := 56.0
	var bounds := Rect2(
		Vector2(m.position.x + margin, m.position.y + margin),
		Vector2(m.size.x - margin * 2.0, m.size.y - margin * 2.0)
	)
	if bounds.has_point(screen) and not cam.is_position_behind(world):
		visible = false
		return

	var center := vp * 0.5
	var dir := screen - center
	if cam.is_position_behind(world) or dir.length_squared() < 1.0:
		# Проекция за спиной: направление по XZ относительно камеры.
		var to := target.global_position - cam.global_position
		to.y = 0.0
		var forward := -cam.global_transform.basis.z
		forward.y = 0.0
		var right := cam.global_transform.basis.x
		right.y = 0.0
		if forward.length_squared() < 0.0001:
			forward = Vector3(0, 0, 1)
		else:
			forward = forward.normalized()
		if right.length_squared() < 0.0001:
			right = Vector3(1, 0, 0)
		else:
			right = right.normalized()
		var sx := to.dot(right)
		var sy := -to.dot(forward)
		dir = Vector2(sx, sy)
	if dir.length_squared() < 1.0:
		visible = false
		return
	dir = dir.normalized()
	var edge := _edge_point(center, dir, bounds)
	position = edge - pivot_offset
	rotation = dir.angle()
	visible = true
	queue_redraw()


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
	draw_circle(c, 26.0, Color(1.0, 0.86, 0.18, 0.92))
	draw_arc(c, 26.0, 0.0, TAU, 28, Color(0.2, 0.12, 0.06), 3.0, true)
	var tip := c + Vector2(18, 0)
	var left := c + Vector2(-14, -14)
	var right := c + Vector2(-14, 14)
	draw_colored_polygon(PackedVector2Array([tip, left, right]), Color(0.18, 0.1, 0.06))
