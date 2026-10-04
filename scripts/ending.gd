extends Control

## Финал дела: радость / решётка.

signal finished(ok: bool)

const FRAME_SEC := 7.0
const PAPER := Color(0.98, 0.94, 0.86)

var _case: Dictionary = {}
var _suspect: Dictionary = {}
var _ok := false
var _phase := 0
var _phase_t := 0.0
var _caption: Label
var _done := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 80
	_case = GameState.current_case()
	_ok = GameState.ending_ok
	_suspect = _find_suspect(GameState.ending_suspect_id)
	_caption = Label.new()
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_font_size_override("font_size", 28)
	_caption.add_theme_color_override("font_color", PAPER)
	_caption.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	_caption.add_theme_constant_override("outline_size", 6)
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_caption)
	_apply_layout()
	get_viewport().size_changed.connect(_apply_layout)
	_set_phase(0)


func _process(delta: float) -> void:
	if _done:
		return
	_phase_t += delta
	queue_redraw()
	if _phase_t >= FRAME_SEC:
		_advance()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed and not _done:
		_advance()
		var vp := get_viewport()
		if vp:
			vp.set_input_as_handled()


func _advance() -> void:
	if _done:
		return
	if _ok and _phase == 0:
		_set_phase(1)
		return
	_finish()


func _set_phase(phase: int) -> void:
	_phase = phase
	_phase_t = 0.0
	var label := str(_suspect.get("label", "Подозреваемый"))
	var cry := str(_suspect.get("cry", "плачет"))
	if _ok:
		if phase == 0:
			_caption.text = "Все радуются! Дело раскрыто."
		else:
			_caption.text = "%s за решёткой и %s." % [label, cry]
	else:
		_caption.text = "«Это был не я!»\n%s %s за решёткой." % [label, cry]
	queue_redraw()


func _finish() -> void:
	_done = true
	finished.emit(_ok)
	queue_free()


func _apply_layout() -> void:
	var m := UiFit.margins(get_viewport())
	_caption.position = Vector2(m.position.x + 24.0, m.end.y - 110.0)
	_caption.size = Vector2(m.size.x - 48.0, 90.0)


func _find_suspect(id: String) -> Dictionary:
	for s in _case.get("suspects", []):
		if str(s["id"]) == id:
			return s
	return {"id": id, "label": "Подозреваемый", "hint": ""}


func _draw() -> void:
	var size := get_viewport_rect().size
	if _ok and _phase == 0:
		_draw_celebrate(size)
	else:
		_draw_jail(size, not _ok)


func _draw_celebrate(size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.55, 0.72, 0.45))
	draw_rect(Rect2(0, 0, size.x, size.y * 0.45), Color(0.55, 0.78, 0.95))
	draw_circle(Vector2(size.x * 0.82, size.y * 0.18), 36.0, Color(1.0, 0.9, 0.35))
	for i in 28:
		var x := fmod(float(i) * 97.3 + _phase_t * 40.0, size.x)
		var y := fmod(float(i) * 53.1 + _phase_t * 55.0, size.y * 0.7)
		var palette: Array[Color] = [
			Color(0.95, 0.3, 0.35),
			Color(0.95, 0.85, 0.2),
			Color(0.3, 0.55, 0.95),
			Color(0.95, 0.5, 0.8),
		]
		var c: Color = palette[i % 4]
		draw_rect(Rect2(x, y, 10, 6), c)
	var base := Vector2(size.x * 0.5, size.y * 0.62)
	var bob := sin(_phase_t * 6.0) * 6.0
	_draw_figure(base + Vector2(-120, bob), 1.0, "kids", true)
	_draw_figure(base + Vector2(-40, bob * 0.7), 1.05, _client_look(), true)
	_draw_figure(base + Vector2(50, bob), 1.0, "man", true)
	_draw_figure(base + Vector2(130, bob * 0.8), 0.95, "girl", true)
	for i in 5:
		var hx := size.x * (0.25 + i * 0.12)
		var hy := size.y * 0.28 + sin(_phase_t * 4.0 + i) * 10.0
		draw_circle(Vector2(hx, hy), 8.0, Color(0.95, 0.35, 0.4, 0.85))


func _draw_jail(size: Vector2, wrongful: bool) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.12, 0.12, 0.16))
	draw_rect(Rect2(size.x * 0.18, size.y * 0.08, size.x * 0.64, size.y * 0.72), Color(0.28, 0.28, 0.32))
	draw_rect(Rect2(size.x * 0.22, size.y * 0.12, size.x * 0.56, size.y * 0.62), Color(0.2, 0.22, 0.26))
	var shake := sin(_phase_t * 18.0) * (4.0 if wrongful else 2.0)
	var cry := absf(sin(_phase_t * 3.0))
	var base := Vector2(size.x * 0.5 + shake, size.y * 0.58)
	var look := _suspect_look(str(_suspect.get("id", "")))
	_draw_figure(base, 1.15, look, false)
	draw_circle(base + Vector2(-10, -70), 3.0 + cry, Color(0.55, 0.75, 0.95, 0.9))
	draw_circle(base + Vector2(12, -66 + cry * 8.0), 3.0, Color(0.55, 0.75, 0.95, 0.9))
	var bars_x0 := size.x * 0.22
	var bars_x1 := size.x * 0.78
	var bars_y0 := size.y * 0.12
	var bars_y1 := size.y * 0.74
	var n := 9
	for i in n:
		var x := lerpf(bars_x0, bars_x1, float(i) / float(n - 1))
		draw_line(Vector2(x, bars_y0), Vector2(x, bars_y1), Color(0.55, 0.55, 0.6), 7.0)
	draw_line(Vector2(bars_x0, bars_y0 + 40), Vector2(bars_x1, bars_y0 + 40), Color(0.55, 0.55, 0.6), 6.0)
	draw_line(Vector2(bars_x0, bars_y1 - 40), Vector2(bars_x1, bars_y1 - 40), Color(0.55, 0.55, 0.6), 6.0)
	if wrongful:
		_draw_ellipse(base + Vector2(0, -55), Vector2(10, 14), Color(0.35, 0.12, 0.12))


func _client_look() -> String:
	var intake = _case.get("intake", {})
	if typeof(intake) == TYPE_DICTIONARY:
		return str(intake.get("client", "person"))
	return "person"


func _suspect_look(id: String) -> String:
	match id:
		"children":
			return "kids"
		"dog":
			return "dog"
		"quarrel":
			return "angry"
		"neighbor":
			return "man"
		"stranger":
			return "stranger"
		"runner":
			return "runner"
		"helper":
			return "helper"
		_:
			return "man"


func _draw_figure(base: Vector2, scale: float, look: String, happy: bool) -> void:
	var skin := Color(0.86, 0.72, 0.58)
	match look:
		"kids":
			_draw_kid(base + Vector2(-28, 0) * scale, scale * 0.9, Color(0.35, 0.55, 0.4), happy)
			_draw_kid(base + Vector2(24, 4) * scale, scale, Color(0.5, 0.4, 0.55), happy)
			return
		"dog":
			_draw_dog(base, scale, happy)
			return
		"girl":
			draw_circle(base + Vector2(0, -78) * scale, 22.0 * scale, skin)
			draw_circle(base + Vector2(-14, -86) * scale, 14.0 * scale, Color(0.35, 0.2, 0.14))
			draw_circle(base + Vector2(14, -86) * scale, 14.0 * scale, Color(0.35, 0.2, 0.14))
			_body(base, scale, Color(0.55, 0.35, 0.42))
		"baker", "helper":
			draw_circle(base + Vector2(0, -78) * scale, 22.0 * scale, skin)
			draw_colored_polygon(PackedVector2Array([
				base + Vector2(-18, -95) * scale,
				base + Vector2(18, -95) * scale,
				base + Vector2(14, -118) * scale,
				base + Vector2(-14, -118) * scale,
			]), Color(0.95, 0.95, 0.92))
			_body(base, scale, Color(0.85, 0.82, 0.75))
		"stranger":
			draw_circle(base + Vector2(0, -78) * scale, 22.0 * scale, skin)
			draw_colored_polygon(PackedVector2Array([
				base + Vector2(-26, -60) * scale,
				base + Vector2(26, -60) * scale,
				base + Vector2(18, -100) * scale,
				base + Vector2(-18, -100) * scale,
			]), Color(0.18, 0.18, 0.22))
			_body(base, scale, Color(0.22, 0.22, 0.26))
		"runner":
			draw_circle(base + Vector2(0, -78) * scale, 22.0 * scale, skin)
			_body(base, scale, Color(0.75, 0.35, 0.28))
		"angry":
			draw_circle(base + Vector2(0, -78) * scale, 22.0 * scale, skin)
			_body(base, scale, Color(0.55, 0.2, 0.2))
		_:
			draw_circle(base + Vector2(0, -78) * scale, 22.0 * scale, skin)
			_body(base, scale, Color(0.3, 0.34, 0.42))
	_face(base + Vector2(0, -78) * scale, scale, happy)


func _body(base: Vector2, scale: float, clothes: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-40, -55) * scale,
		base + Vector2(40, -55) * scale,
		base + Vector2(32, 30) * scale,
		base + Vector2(-32, 30) * scale,
	]), clothes)
	draw_rect(Rect2(base + Vector2(-28, 28) * scale, Vector2(20, 40) * scale), Color(0.2, 0.18, 0.16))
	draw_rect(Rect2(base + Vector2(8, 28) * scale, Vector2(20, 40) * scale), Color(0.2, 0.18, 0.16))


func _face(center: Vector2, scale: float, happy: bool) -> void:
	var eye := Color(0.12, 0.1, 0.1)
	draw_circle(center + Vector2(-8, -2) * scale, 2.5 * scale, eye)
	draw_circle(center + Vector2(8, -2) * scale, 2.5 * scale, eye)
	if happy:
		draw_arc(center + Vector2(0, 6) * scale, 8.0 * scale, PI * 0.15, PI * 0.85, 12, Color(0.35, 0.15, 0.12), 2.5, true)
	else:
		draw_arc(center + Vector2(0, 12) * scale, 8.0 * scale, PI * 1.15, PI * 1.85, 12, Color(0.35, 0.15, 0.12), 2.5, true)


func _draw_kid(base: Vector2, scale: float, shirt: Color, happy: bool) -> void:
	draw_circle(base + Vector2(0, -52) * scale, 16.0 * scale, Color(0.86, 0.72, 0.58))
	draw_rect(Rect2(base + Vector2(-18, -38) * scale, Vector2(36, 48) * scale), shirt)
	draw_rect(Rect2(base + Vector2(-16, 8) * scale, Vector2(12, 28) * scale), Color(0.25, 0.28, 0.4))
	draw_rect(Rect2(base + Vector2(4, 8) * scale, Vector2(12, 28) * scale), Color(0.25, 0.28, 0.4))
	_face(base + Vector2(0, -52) * scale, scale * 0.85, happy)


func _draw_dog(base: Vector2, scale: float, happy: bool) -> void:
	var fur := Color(0.72, 0.55, 0.32)
	draw_circle(base + Vector2(0, -40) * scale, 26.0 * scale, fur)
	draw_circle(base + Vector2(-22, -55) * scale, 10.0 * scale, fur)
	draw_circle(base + Vector2(22, -55) * scale, 10.0 * scale, fur)
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-30, -20) * scale,
		base + Vector2(30, -20) * scale,
		base + Vector2(24, 35) * scale,
		base + Vector2(-24, 35) * scale,
	]), fur)
	_face(base + Vector2(0, -40) * scale, scale, happy)


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts: PackedVector2Array = []
	for i in 16:
		var a := TAU * float(i) / 16.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
