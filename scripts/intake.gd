extends Control

## Стойка детектива от первого лица: заявитель подходит и просит помочь.

const INK := Color(0.16, 0.11, 0.08)
const PAPER := Color(0.98, 0.94, 0.86)
const WOOD := Color(0.42, 0.28, 0.18)
const WOOD_DARK := Color(0.28, 0.18, 0.12)
const LAMP := Color(1.0, 0.86, 0.55)
const DECLINE := Color(0.92, 0.72, 0.68)
const ACCEPT := Color(0.62, 0.86, 0.55)

var _case: Dictionary = {}
var _intake: Dictionary = {}
var _time := 0.0
var _arrive := 0.0
var _hits: Array[Dictionary] = []
var _pointer_down := false
var _pointer_start := Vector2.ZERO
var _did_drag := false
var _speech: Label
var _name_label: Label
var _btn_decline: ColorRect
var _btn_accept: ColorRect
var _lbl_decline: Label
var _lbl_accept: Label
var _bubble: Panel


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_case = GameState.current_case()
	_intake = _case.get("intake", {}) as Dictionary
	_build_ui()
	_apply_layout()
	get_viewport().size_changed.connect(_apply_layout)
	var tween := create_tween()
	tween.tween_property(self, "_arrive", 1.0, 1.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
		var vp := get_viewport()
		if vp:
			vp.set_input_as_handled()
	elif event is InputEventScreenDrag:
		if _pointer_down and event.position.distance_to(_pointer_start) > 18.0:
			_did_drag = true
		var vp2 := get_viewport()
		if vp2:
			vp2.set_input_as_handled()


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_pointer_down = true
		_pointer_start = event.position
		_did_drag = false
		return
	if not _pointer_down:
		return
	_pointer_down = false
	if _did_drag:
		return
	var grow := UiFit.touch_grow()
	for hit in _hits:
		var node: Control = hit["node"]
		if node.get_global_rect().grow(grow).has_point(event.position):
			_run(str(hit["action"]))
			return


func _run(action: String) -> void:
	match action:
		"decline":
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
		"accept":
			get_tree().change_scene_to_file("res://scenes/main.tscn")


func _build_ui() -> void:
	_bubble = Panel.new()
	_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.border_color = INK
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	_bubble.add_theme_stylebox_override("panel", style)
	add_child(_bubble)

	_name_label = Label.new()
	_name_label.text = str(_intake.get("client_name", "Заявитель"))
	_name_label.add_theme_font_size_override("font_size", 24)
	_name_label.add_theme_color_override("font_color", INK)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble.add_child(_name_label)

	_speech = Label.new()
	_speech.text = str(_intake.get("speech", _case.get("brief", "")))
	_speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_speech.add_theme_font_size_override("font_size", 22)
	_speech.add_theme_color_override("font_color", Color(0.22, 0.16, 0.12))
	_speech.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble.add_child(_speech)

	_btn_decline = _make_button("Спасибо, откажусь", DECLINE)
	_lbl_decline = _btn_decline.get_child(0) as Label
	_btn_accept = _make_button("Конечно, я вам помогу", ACCEPT)
	_lbl_accept = _btn_accept.get_child(0) as Label
	_hits = [
		{"node": _btn_decline, "action": "decline"},
		{"node": _btn_accept, "action": "accept"},
	]


func _make_button(text: String, bg: Color) -> ColorRect:
	var btn := ColorRect.new()
	btn.color = bg
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(btn)
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", INK)
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(lbl)
	return btn


func _apply_layout() -> void:
	var m := UiFit.margins(get_viewport())
	var compact := UiFit.is_compact(get_viewport())
	var bubble_h := 175.0 if compact else 200.0
	_bubble.position = Vector2(m.position.x + 18.0, m.position.y + 16.0)
	_bubble.size = Vector2(m.size.x - 36.0, bubble_h)
	_name_label.position = Vector2(14, 8)
	_name_label.size = Vector2(_bubble.size.x - 28.0, 28.0)
	_speech.position = Vector2(14, 36)
	_speech.size = Vector2(_bubble.size.x - 28.0, bubble_h - 50.0)

	var btn_h := 70.0 if compact else 78.0
	var gap := 12.0
	var btn_w := (m.size.x - 36.0 - gap) * 0.5
	var by := m.end.y - btn_h - 14.0
	_btn_decline.position = Vector2(m.position.x + 18.0, by)
	_btn_decline.size = Vector2(btn_w, btn_h)
	_btn_accept.position = Vector2(m.position.x + 18.0 + btn_w + gap, by)
	_btn_accept.size = Vector2(btn_w, btn_h)
	queue_redraw()


func _draw() -> void:
	var size := get_viewport_rect().size
	_draw_room(size)
	_draw_client(size)
	_draw_desk(size)
	_draw_hands(size)


func _draw_room(size: Vector2) -> void:
	# Стены и тёплый свет лампы — вид из-за стойки.
	var top := Color(0.18, 0.2, 0.28)
	var mid := Color(0.45, 0.38, 0.3)
	var floor_c := Color(0.32, 0.26, 0.2)
	draw_rect(Rect2(Vector2.ZERO, size), top)
	draw_rect(Rect2(0, size.y * 0.38, size.x, size.y * 0.62), floor_c)
	# Градиент окна / улицы сзади
	for i in 8:
		var t := float(i) / 8.0
		var y := size.y * (0.12 + t * 0.26)
		var c := top.lerp(Color(0.55, 0.48, 0.4), t)
		draw_rect(Rect2(0, y, size.x, size.y * 0.04), c)
	# Дверь сзади
	var door := Rect2(size.x * 0.38, size.y * 0.08, size.x * 0.24, size.y * 0.42)
	draw_rect(door, Color(0.22, 0.16, 0.12))
	draw_rect(door.grow(-6), Color(0.35, 0.25, 0.18))
	# Лампа сверху
	var lamp_x := size.x * 0.5
	draw_circle(Vector2(lamp_x, size.y * 0.02), 18.0, LAMP)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(lamp_x - 10, size.y * 0.03),
			Vector2(lamp_x + 10, size.y * 0.03),
			Vector2(size.x * 0.72, size.y * 0.55),
			Vector2(size.x * 0.28, size.y * 0.55),
		]),
		Color(1, 0.9, 0.6, 0.08)
	)
	# Надпись на стене
	draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.08, size.y * 0.07), "ТИХИЙ ГОРОД · ПРИЁМ", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.85, 0.78, 0.65, 0.55))


func _draw_client(size: Vector2) -> void:
	var kind := str(_intake.get("client", "person"))
	var t := clampf(_arrive, 0.0, 1.0)
	var bob := sin(_time * 2.2) * 3.0
	var base := Vector2(size.x * 0.5, size.y * 0.52 + bob)
	# Подходит из двери: сначала дальше/выше, потом ближе.
	base.y = lerpf(size.y * 0.36, size.y * 0.52, t) + bob
	var scale := lerpf(0.55, 1.0, t)
	match kind:
		"kids":
			_draw_kid(base + Vector2(-70 * scale, 0), scale * 0.9, Color(0.35, 0.55, 0.4))
			_draw_kid(base + Vector2(10 * scale, 8), scale, Color(0.45, 0.4, 0.55))
			_draw_kid(base + Vector2(75 * scale, 4), scale * 0.85, Color(0.55, 0.42, 0.3))
		"girl":
			_draw_person(base, scale, Color(0.55, 0.35, 0.42), true)
		"baker":
			_draw_person(base, scale, Color(0.85, 0.82, 0.75), false)
			# Колпак
			draw_colored_polygon(
				PackedVector2Array([
					base + Vector2(-22, -88) * scale,
					base + Vector2(22, -88) * scale,
					base + Vector2(16, -118) * scale,
					base + Vector2(-16, -118) * scale,
				]),
				Color(0.95, 0.95, 0.92)
			)
		"man":
			_draw_person(base, scale, Color(0.3, 0.34, 0.42), false)
		_:
			_draw_person(base, scale, Color(0.4, 0.36, 0.32), false)


func _draw_kid(base: Vector2, scale: float, shirt: Color) -> void:
	draw_circle(base + Vector2(0, -52) * scale, 16.0 * scale, Color(0.86, 0.72, 0.58))
	draw_rect(Rect2(base + Vector2(-18, -38) * scale, Vector2(36, 48) * scale), shirt)
	draw_rect(Rect2(base + Vector2(-16, 8) * scale, Vector2(12, 28) * scale), Color(0.25, 0.28, 0.4))
	draw_rect(Rect2(base + Vector2(4, 8) * scale, Vector2(12, 28) * scale), Color(0.25, 0.28, 0.4))


func _draw_person(base: Vector2, scale: float, clothes: Color, girl: bool) -> void:
	var skin := Color(0.86, 0.72, 0.58)
	draw_circle(base + Vector2(0, -78) * scale, 22.0 * scale, skin)
	if girl:
		# Волосы
		draw_circle(base + Vector2(-14, -86) * scale, 14.0 * scale, Color(0.35, 0.2, 0.14))
		draw_circle(base + Vector2(14, -86) * scale, 14.0 * scale, Color(0.35, 0.2, 0.14))
		draw_circle(base + Vector2(0, -96) * scale, 18.0 * scale, Color(0.35, 0.2, 0.14))
	else:
		draw_rect(Rect2(base + Vector2(-20, -98) * scale, Vector2(40, 14) * scale), Color(0.18, 0.16, 0.14))
	# Плечи / пальто
	draw_colored_polygon(
		PackedVector2Array([
			base + Vector2(-40, -55) * scale,
			base + Vector2(40, -55) * scale,
			base + Vector2(32, 30) * scale,
			base + Vector2(-32, 30) * scale,
		]),
		clothes
	)
	draw_rect(Rect2(base + Vector2(-28, 28) * scale, Vector2(20, 40) * scale), Color(0.2, 0.18, 0.16))
	draw_rect(Rect2(base + Vector2(8, 28) * scale, Vector2(20, 40) * scale), Color(0.2, 0.18, 0.16))


func _draw_desk(size: Vector2) -> void:
	var top_y := size.y * 0.58
	# Столешница крупным планом
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, top_y),
			Vector2(size.x, top_y),
			Vector2(size.x, size.y),
			Vector2(0, size.y),
		]),
		WOOD
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, top_y),
			Vector2(size.x, top_y),
			Vector2(size.x * 0.92, top_y + 28),
			Vector2(size.x * 0.08, top_y + 28),
		]),
		WOOD_DARK
	)
	# Блокнот и ручка на стойке
	var pad := Rect2(size.x * 0.18, top_y + 40, size.x * 0.28, size.y * 0.18)
	draw_rect(pad, PAPER)
	draw_rect(pad.grow(-3), Color(0.95, 0.9, 0.8))
	for i in 4:
		var ly := pad.position.y + 18 + i * 14
		draw_line(Vector2(pad.position.x + 12, ly), Vector2(pad.end.x - 12, ly), Color(0.75, 0.7, 0.62), 1.5)
	draw_line(
		Vector2(size.x * 0.52, top_y + 55),
		Vector2(size.x * 0.62, top_y + 120),
		Color(0.15, 0.12, 0.1),
		3.0
	)
	# Край стойки
	draw_line(Vector2(0, top_y), Vector2(size.x, top_y), Color(0.15, 0.1, 0.08), 3.0)


func _draw_hands(size: Vector2) -> void:
	# Свои руки у нижнего края — вид от первого лица.
	var skin := Color(0.78, 0.62, 0.5)
	var y := size.y * 0.92
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(size.x * 0.08, size.y),
			Vector2(size.x * 0.28, y),
			Vector2(size.x * 0.34, size.y),
		]),
		skin
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(size.x * 0.66, size.y),
			Vector2(size.x * 0.72, y),
			Vector2(size.x * 0.92, size.y),
		]),
		skin
	)
