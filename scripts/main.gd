extends Node2D

const GRID_SIZE := 256.0
const SWIPE_THRESHOLD := 48.0
const MOVE_COOLDOWN := 0.16
const NEXT_MARKER_DELAY := 1.0
const HINT_IDLE := "Знак — услышать. Место — осмотреть. Книга — дело."

const WaveScene := preload("res://scenes/wave.tscn")
const MarkerScene := preload("res://scenes/attention_marker.tscn")
const EndingScene := preload("res://scenes/ending.tscn")

@onready var camera: Camera2D = $Camera2D
@onready var waves: Node2D = $Waves
@onready var hint: Label = $UI/Hint
@onready var toast: Label = $UI/Toast
@onready var arrow: Control = $UI/Arrow
@onready var menu_button: Label = $UI/MenuButton
@onready var journal: Control = $UI/Journal

var _grid_pos := Vector2i.ZERO
var _move_cd := 0.0
var _pointer_down := false
var _pointer_start := Vector2.ZERO
var _did_swipe := false
var _camera_tween: Tween
var _toast_tween: Tween

var _places: Array[MapPlace] = []
var _marker: Node2D = null
var _marker_index := 0
var _waiting_for_resolve := false
var _active_event: Dictionary = {}
var _case: Dictionary = {}


func _ready() -> void:
	_case = GameState.current_case()
	hint.text = HINT_IDLE
	toast.modulate.a = 0.0
	journal.accused.connect(_on_accused)
	_apply_safe_ui()
	get_viewport().size_changed.connect(_apply_safe_ui)
	_spawn_places()
	get_tree().create_timer(0.9).timeout.connect(_spawn_next_marker)


func _apply_safe_ui() -> void:
	if hint == null or menu_button == null or toast == null or journal == null:
		return
	var m := UiFit.margins(get_viewport())
	var right_pad := get_viewport_rect().size.x - m.end.x
	var bottom_pad := get_viewport_rect().size.y - m.end.y
	hint.offset_left = m.position.x + 8.0
	hint.offset_top = m.position.y + 2.0
	hint.offset_right = m.position.x + 620.0
	hint.offset_bottom = m.position.y + 38.0
	menu_button.offset_left = -160.0 - right_pad
	menu_button.offset_right = -12.0 - right_pad
	menu_button.offset_top = m.position.y
	menu_button.offset_bottom = m.position.y + 44.0
	toast.offset_left = m.position.x + 24.0
	toast.offset_right = -24.0 - right_pad
	toast.offset_top = m.position.y + 40.0
	toast.offset_bottom = m.position.y + 120.0
	var book := journal.get_node("ClosedIcon") as Control
	if book:
		book.offset_left = -112.0 - right_pad
		book.offset_right = -12.0 - right_pad
		book.offset_top = -140.0 - bottom_pad
		book.offset_bottom = -12.0 - bottom_pad


func _process(delta: float) -> void:
	_move_cd = maxf(_move_cd - delta, 0.0)
	if journal.is_open or _move_cd > 0.0:
		return

	var dir := Vector2i.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1
	elif Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1

	if dir != Vector2i.ZERO:
		_move_camera(dir)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_mark_input_handled()
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_mark_input_handled()
		if journal.is_open:
			if event.relative.length() > 2.0:
				_did_swipe = true
			journal.handle_open_drag(event.relative)
			return
		_handle_drag(event)


func _mark_input_handled() -> void:
	var vp := get_viewport()
	if vp:
		vp.set_input_as_handled()


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_pointer_down = true
		_pointer_start = event.position
		_did_swipe = false
		return

	if not _pointer_down:
		return
	_pointer_down = false

	if _did_swipe:
		return

	if journal.is_open:
		journal.handle_open_tap(event.position)
		return

	var grow := UiFit.touch_grow()
	if menu_button.get_global_rect().grow(grow).has_point(event.position):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		return

	if journal.contains_closed(event.position):
		journal.open_journal()
		return

	if arrow.visible and arrow.get_global_rect().grow(grow).has_point(event.position):
		_step_toward_marker()
		return

	_try_interact(_screen_to_world(event.position))


func _handle_drag(event: InputEventScreenDrag) -> void:
	if not _pointer_down or _did_swipe:
		return

	var delta: Vector2 = event.position - _pointer_start
	if delta.length() < SWIPE_THRESHOLD:
		return

	_did_swipe = true
	var dir := Vector2i.ZERO
	if absf(delta.x) >= absf(delta.y):
		dir.x = 1 if delta.x > 0.0 else -1
	else:
		dir.y = 1 if delta.y > 0.0 else -1
	_move_camera(dir)


func _move_camera(dir: Vector2i) -> void:
	_grid_pos += dir
	_move_cd = MOVE_COOLDOWN
	var target := Vector2(_grid_pos) * GRID_SIZE
	if _camera_tween and _camera_tween.is_running():
		_camera_tween.kill()
	_camera_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_camera_tween.tween_property(camera, "position", target, 0.18)
	_camera_tween.finished.connect(_refresh_place_hint)


func _step_toward_marker() -> void:
	if _marker == null or not is_instance_valid(_marker):
		return
	var delta := _marker.global_position - camera.global_position
	var dir := Vector2i.ZERO
	if absf(delta.x) >= absf(delta.y):
		if absf(delta.x) < 24.0:
			return
		dir.x = 1 if delta.x > 0.0 else -1
	else:
		if absf(delta.y) < 24.0:
			return
		dir.y = 1 if delta.y > 0.0 else -1
	_move_camera(dir)


func _try_interact(world_pos: Vector2) -> void:
	if _marker and is_instance_valid(_marker) and _marker.contains(world_pos):
		_inspect_marker()
		return
	for place in _places:
		if place.contains(world_pos):
			_inspect_place(place)
			return


func _inspect_place(place: MapPlace) -> void:
	var heard := str(journal.heard_text(place.place_id))
	if heard.is_empty():
		_show_toast("%s. %s" % [place.place_name, place.idle_text])
	else:
		_show_toast("%s. %s" % [place.place_name, heard])


func _inspect_marker() -> void:
	if _marker == null or _active_event.is_empty():
		return
	var kind: SoundCatalog.Kind = _active_event["kind"]
	_spawn_wave(_marker.global_position, SoundCatalog.color(kind), 210.0, 1.15)
	journal.add_observation(_active_event)
	_show_toast("Записано · %s · %s" % [_active_event["time"], _active_event["place"]])
	arrow.clear_target()
	_marker.queue_free()
	_marker = null
	_active_event = {}
	_waiting_for_resolve = true
	get_tree().create_timer(NEXT_MARKER_DELAY).timeout.connect(_resolve_marker)


func _resolve_marker() -> void:
	_waiting_for_resolve = false
	_spawn_next_marker()


func _spawn_next_marker() -> void:
	if _marker != null or _waiting_for_resolve:
		return
	var events: Array = _case["events"]
	if _marker_index >= events.size():
		if not journal.solved:
			_show_toast("Все волны записаны. Открой книгу.")
		return
	var event: Dictionary = events[_marker_index]
	_marker_index += 1
	var marker := MarkerScene.instantiate()
	marker.position = MapLayout.pos_of(str(event["place_id"]))
	marker.setup(event["kind"])
	add_child(marker)
	_marker = marker
	_active_event = event
	arrow.set_target(marker)


func _spawn_places() -> void:
	var root := Node2D.new()
	root.name = "Places"
	root.z_index = 3
	add_child(root)
	for id in MapLayout.ids():
		var place := MapPlace.new()
		place.setup(id)
		root.add_child(place)
		_places.append(place)


func _refresh_place_hint() -> void:
	for place in _places:
		if place.global_position.distance_to(camera.global_position) < 150.0:
			hint.text = "%s — нажми, чтобы осмотреть" % place.place_name
			return
	hint.text = HINT_IDLE


func _on_accused(suspect_id: String) -> void:
	if journal.solved:
		return
	var ok := journal.apply_verdict(suspect_id)
	GameState.start_ending(ok, suspect_id)
	if journal.is_open:
		journal.close_journal()
	var ending := EndingScene.instantiate()
	$UI.add_child(ending)
	ending.finished.connect(_on_ending_finished)


func _on_ending_finished(ok: bool) -> void:
	if ok:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	else:
		_show_toast("Не сходится. Сверь время и цвет — попробуй снова.")


func _show_toast(text: String) -> void:
	toast.text = text
	toast.modulate.a = 1.0
	if _toast_tween and _toast_tween.is_running():
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(2.4)
	_toast_tween.tween_property(toast, "modulate:a", 0.0, 0.45)


func _spawn_wave(world_pos: Vector2, color: Color, max_radius: float = 220.0, lifetime: float = 1.15) -> void:
	var wave := WaveScene.instantiate()
	wave.position = world_pos
	wave.color = color
	wave.max_radius = max_radius
	wave.lifetime = lifetime
	waves.add_child(wave)


func _screen_to_world(screen_pos: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * screen_pos
