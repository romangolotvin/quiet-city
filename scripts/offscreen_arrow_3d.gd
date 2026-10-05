extends Control

## Крупная стрелка к цели в 3D (событие / база / NPC).

var target: Node3D = null
var _label := "Сюда"
var _smooth_pos := Vector2.ZERO
var _smooth_rot := 0.0
var _has_smooth := false
var _font: Font


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(120, 120)
	pivot_offset = size * 0.5
	visible = false
	_font = ThemeDB.fallback_font


func set_target_3d(node: Node3D, caption: String = "") -> void:
	target = node
	_label = caption if not caption.is_empty() else "Сюда"


func clear_target() -> void:
	target = null
	visible = false
	_has_smooth = false


func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		visible = false
		_has_smooth = false
		return
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		visible = false
		return
	var world := target.global_position + Vector3(0, 24, 0)
	var behind := cam.is_position_behind(world)
	var screen := cam.unproject_position(world)
	var vp := get_viewport_rect().size
	var m := UiFit.margins(get_viewport())
	var margin := 72.0
	var bounds := Rect2(
		Vector2(m.position.x + margin, m.position.y + margin),
		Vector2(m.size.x - margin * 2.0, m.size.y - margin * 2.0)
	)
	if bounds.has_point(screen) and not behind:
		visible = false
		_has_smooth = false
		return

	var center := vp * 0.5
	var dir := screen - center
	if behind or dir.length_squared() < 1.0:
		# Цель за камерой — направление только по XZ относительно камеры.
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
	if dir.length_squared() < 0.0001:
		visible = false
		return
	dir = dir.normalized()
	var edge := _edge_point(center, dir, bounds)
	var target_pos := edge - pivot_offset
	var target_rot := dir.angle()
	if not _has_smooth:
		_smooth_pos = target_pos
		_smooth_rot = target_rot
		_has_smooth = true
	else:
		var k := clampf(delta * 14.0, 0.0, 1.0)
		_smooth_pos = _smooth_pos.lerp(target_pos, k)
		_smooth_rot = lerp_angle(_smooth_rot, target_rot, k)
	position = _smooth_pos
	rotation = _smooth_rot
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
	# Крупный яркий диск + стрелка; подпись без вращения читается отдельно.
	draw_set_transform(c, -rotation, Vector2.ONE)
	draw_circle(Vector2.ZERO, 38.0, Color(1.0, 0.82, 0.12, 0.96))
	draw_arc(Vector2.ZERO, 38.0, 0.0, TAU, 36, Color(0.18, 0.1, 0.04), 4.5, true)
	draw_circle(Vector2.ZERO, 30.0, Color(1.0, 0.92, 0.35, 0.55))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var tip := c + Vector2(28, 0)
	var left := c + Vector2(-20, -20)
	var right := c + Vector2(-20, 20)
	draw_colored_polygon(PackedVector2Array([tip, left, right]), Color(0.14, 0.08, 0.04))
	# Подпись экраном вверх (компенсируем rotation контрола).
	if _font and not _label.is_empty():
		draw_set_transform(c + Vector2(0, 52), -rotation, Vector2.ONE)
		var fs := 20
		var text_size := _font.get_string_size(_label, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
		var text_pos := Vector2(-text_size.x * 0.5, fs * 0.35)
		draw_string(_font, text_pos + Vector2(2, 2), _label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.1, 0.06, 0.02, 0.7))
		draw_string(_font, text_pos, _label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1.0, 0.96, 0.75))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
