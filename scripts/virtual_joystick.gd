extends Control

## Экранный analog-джойстик для ходьбы на телефоне.

signal direction_changed(dir: Vector2)

const BASE_RADIUS := 100.0
const KNOB_RADIUS := 42.0
const DEADZONE := 0.12

var _active := false
var _pointer_id := -1
var _knob_offset := Vector2.ZERO
var _dir := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(BASE_RADIUS * 2.0, BASE_RADIUS * 2.0)
	size = custom_minimum_size
	visible = DisplayServer.is_touchscreen_available()
	queue_redraw()


func get_direction() -> Vector2:
	return _dir


func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		_on_touch(event)
		accept_event()
	elif event is InputEventScreenDrag:
		_on_drag(event)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Удобно проверять в редакторе / на ПК с тачскрином-эмуляцией.
		if event.pressed:
			_begin(event.position, -2)
		else:
			_end(-2)
		accept_event()
	elif event is InputEventMouseMotion and _active and _pointer_id == -2:
		_update_knob(event.position)
		accept_event()


func _on_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _active:
			return
		_begin(event.position, event.index)
	else:
		_end(event.index)


func _on_drag(event: InputEventScreenDrag) -> void:
	if not _active or event.index != _pointer_id:
		return
	_update_knob(event.position)


func _begin(local_pos: Vector2, pointer_id: int) -> void:
	_active = true
	_pointer_id = pointer_id
	_update_knob(local_pos)


func _end(pointer_id: int) -> void:
	if pointer_id != _pointer_id:
		return
	_active = false
	_pointer_id = -1
	_knob_offset = Vector2.ZERO
	_set_dir(Vector2.ZERO)
	queue_redraw()


func _update_knob(local_pos: Vector2) -> void:
	var center := size * 0.5
	var offset := local_pos - center
	var max_len := BASE_RADIUS - KNOB_RADIUS * 0.35
	if offset.length() > max_len:
		offset = offset.normalized() * max_len
	_knob_offset = offset
	var raw := offset / max_len
	if raw.length() < DEADZONE:
		_set_dir(Vector2.ZERO)
	else:
		# Масштаб после deadzone, чтобы сразу после порога не прыгало.
		var t := (raw.length() - DEADZONE) / (1.0 - DEADZONE)
		_set_dir(raw.normalized() * clampf(t, 0.0, 1.0))
	queue_redraw()


func _set_dir(dir: Vector2) -> void:
	if dir.is_equal_approx(_dir):
		return
	_dir = dir
	direction_changed.emit(_dir)


func _draw() -> void:
	var center := size * 0.5
	# Полупрозрачная база — читается и на светлой, и на тёмной земле.
	draw_circle(center, BASE_RADIUS, Color(0.12, 0.1, 0.08, 0.38))
	draw_arc(center, BASE_RADIUS, 0.0, TAU, 48, Color(1, 0.97, 0.9, 0.72), 3.5, true)
	draw_arc(center, BASE_RADIUS * 0.55, 0.0, TAU, 32, Color(1, 0.97, 0.9, 0.22), 2.0, true)
	var knob_pos := center + _knob_offset
	draw_circle(knob_pos, KNOB_RADIUS, Color(0.98, 0.94, 0.86, 0.88))
	draw_arc(knob_pos, KNOB_RADIUS, 0.0, TAU, 36, Color(0.16, 0.11, 0.08, 0.85), 3.0, true)
	draw_circle(knob_pos, KNOB_RADIUS * 0.35, Color(0.16, 0.11, 0.08, 0.35))
