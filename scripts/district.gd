extends Node3D

## Жилой квартал (low-poly 3D): ходьба, жители, волны, 3 камеры.

const EndingScene := preload("res://scenes/ending.tscn")
const PlayerScript := preload("res://scripts/player_3d.gd")
const NpcScript := preload("res://scripts/npc_resident_3d.gd")
const DeviceScript := preload("res://scripts/device_ui.gd")
const TabletIconScript := preload("res://scripts/tablet_icon.gd")
const MapPlaceScript := preload("res://scripts/map_place_3d.gd")
const CityMapScript := preload("res://scripts/city_map_3d.gd")
const JoystickScript := preload("res://scripts/virtual_joystick.gd")
const CameraScript := preload("res://scripts/camera_controller.gd")
const WaveScript := preload("res://scripts/wave_3d.gd")

const INK := Color(0.16, 0.11, 0.08)
const CATCH_RADIUS := 110.0

var _player: CharacterBody3D
var _cams: Node3D
var _npcs: Array[Node3D] = []
var _places: Array[Node3D] = []
var _waves: Node3D
var _ui: CanvasLayer
var _hint: Label
var _toast: Label
var _menu_btn: Label
var _cam_btn: Label
var _device_btn: Control
var _device: Control
var _dialog: Control
var _dialog_title: Label
var _dialog_body: Label
var _dialog_hits: Array[Dictionary] = []
var _toast_tween: Tween
var _joystick: Control
var _pointer_down := false
var _pointer_start := Vector2.ZERO
var _did_drag := false
var _touch_move := false
var _bounds := Rect2()
var _talk_npc: Node3D = null


func _ready() -> void:
	_compute_bounds()
	_build_world()
	_build_ui()
	_apply_safe_ui()
	get_viewport().size_changed.connect(_apply_safe_ui)
	_show_toast("Погуляй по кварталу. Жёлтая точка — у человека есть дело. C — смена камеры.")


func _compute_bounds() -> void:
	var gb := MapLayout.grid_bounds()
	var pad := 180.0
	_bounds = Rect2(
		Vector2(gb.position.x * 256.0 - pad, gb.position.y * 256.0 - pad),
		Vector2(gb.size.x * 256.0 + pad * 2.0, gb.size.y * 256.0 + pad * 2.0)
	)


func _build_world() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.72, 0.88, 0.98)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.92, 0.9, 0.86)
	environment.ambient_light_energy = 0.55
	env.environment = environment
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, 35, 0)
	sun.light_energy = 1.05
	sun.shadow_enabled = false
	add_child(sun)

	var city := Node3D.new()
	city.set_script(CityMapScript)
	add_child(city)

	_waves = Node3D.new()
	add_child(_waves)

	var places_root := Node3D.new()
	add_child(places_root)
	for id in MapLayout.ids():
		var place := Node3D.new()
		place.set_script(MapPlaceScript)
		places_root.add_child(place)
		place.setup(id)
		_places.append(place)

	var npc_root := Node3D.new()
	add_child(npc_root)
	for data in _npc_data():
		var npc := Node3D.new()
		npc.set_script(NpcScript)
		npc_root.add_child(npc)
		npc.setup(data)
		_npcs.append(npc)

	_player = CharacterBody3D.new()
	_player.set_script(PlayerScript)
	_player.position = MapLayout.to_3d(Vector2(0, 40), 0.0)
	var body := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 12.0
	shape.height = 36.0
	body.shape = shape
	body.position = Vector3(0, 18, 0)
	_player.add_child(body)
	add_child(_player)

	_cams = Node3D.new()
	_cams.set_script(CameraScript)
	add_child(_cams)
	_cams.setup(_player)


func _npc_data() -> Array[Dictionary]:
	return [
		{
			"id": "npc_kids",
			"case_id": "lost_ball",
			"name": "Дети",
			"look": "kids",
			"pos": MapLayout.pos_of("yard") + Vector2(-160, 120),
		},
		{
			"id": "npc_girl",
			"case_id": "stolen_bag",
			"name": "Девушка",
			"look": "girl",
			"pos": MapLayout.pos_of("gate") + Vector2(150, -110),
		},
		{
			"id": "npc_neighbor",
			"case_id": "night_shout",
			"name": "Сосед",
			"look": "man",
			"pos": MapLayout.pos_of("porch") + Vector2(-140, 130),
		},
		{
			"id": "npc_baker",
			"case_id": "broken_window",
			"name": "Пекарь",
			"look": "baker",
			"pos": MapLayout.pos_of("bakery") + Vector2(150, 130),
		},
	]


func _build_ui() -> void:
	_ui = CanvasLayer.new()
	_ui.layer = 10
	add_child(_ui)

	_hint = Label.new()
	_hint.add_theme_font_size_override("font_size", 22)
	_hint.add_theme_color_override("font_color", INK)
	_hint.add_theme_color_override("font_outline_color", Color(1, 0.97, 0.9, 0.9))
	_hint.add_theme_constant_override("outline_size", 4)
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_hint)

	_toast = Label.new()
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast.add_theme_font_size_override("font_size", 22)
	_toast.add_theme_color_override("font_color", INK)
	_toast.add_theme_color_override("font_outline_color", Color(1, 0.97, 0.9, 0.95))
	_toast.add_theme_constant_override("outline_size", 4)
	_toast.modulate.a = 0.0
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_toast)

	_menu_btn = Label.new()
	_menu_btn.text = "Меню"
	_menu_btn.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_menu_btn.add_theme_font_size_override("font_size", 24)
	_menu_btn.add_theme_color_override("font_color", INK)
	_menu_btn.add_theme_color_override("font_outline_color", Color(1, 0.97, 0.9, 0.9))
	_menu_btn.add_theme_constant_override("outline_size", 4)
	_menu_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_menu_btn)

	_cam_btn = Label.new()
	_cam_btn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cam_btn.add_theme_font_size_override("font_size", 20)
	_cam_btn.add_theme_color_override("font_color", INK)
	_cam_btn.add_theme_color_override("font_outline_color", Color(1, 0.97, 0.9, 0.9))
	_cam_btn.add_theme_constant_override("outline_size", 4)
	_cam_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_cam_btn)
	_refresh_cam_btn()

	_device_btn = Control.new()
	_device_btn.set_script(TabletIconScript)
	_device_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_device_btn)

	_joystick = Control.new()
	_joystick.set_script(JoystickScript)
	_ui.add_child(_joystick)
	_joystick.direction_changed.connect(_on_joystick_dir)

	_device = Control.new()
	_device.set_script(DeviceScript)
	_ui.add_child(_device)
	_device.accused.connect(_on_accused)
	_device.closed.connect(_refresh_hint)

	_build_dialog()


func _build_dialog() -> void:
	_dialog = Control.new()
	_dialog.visible = false
	_dialog.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dialog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_dialog)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.35)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dialog.add_child(dim)

	var panel := Panel.new()
	panel.name = "Panel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.98, 0.94, 0.86)
	style.set_border_width_all(2)
	style.border_color = INK
	style.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel", style)
	_dialog.add_child(panel)

	_dialog_title = Label.new()
	_dialog_title.add_theme_font_size_override("font_size", 24)
	_dialog_title.add_theme_color_override("font_color", INK)
	panel.add_child(_dialog_title)

	_dialog_body = Label.new()
	_dialog_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialog_body.add_theme_font_size_override("font_size", 20)
	_dialog_body.add_theme_color_override("font_color", Color(0.25, 0.18, 0.12))
	panel.add_child(_dialog_body)


func _process(_delta: float) -> void:
	_clamp_player()
	_refresh_hint()
	_sync_joystick_visibility()


func _clamp_player() -> void:
	if _player == null:
		return
	_player.position.x = clampf(_player.position.x, _bounds.position.x, _bounds.end.x)
	_player.position.z = clampf(_player.position.z, _bounds.position.y, _bounds.end.y)
	if _player.position.y < 0.0:
		_player.position.y = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C:
			_cycle_camera()
			_mark_handled()
			return
	if event is InputEventScreenTouch:
		_handle_touch(event)
		_mark_handled()
	elif event is InputEventScreenDrag:
		_handle_drag(event)
		_mark_handled()


func _mark_handled() -> void:
	var vp := get_viewport()
	if vp:
		vp.set_input_as_handled()


func _cycle_camera() -> void:
	if _cams and _cams.has_method("cycle"):
		_cams.cycle()
	_refresh_cam_btn()
	_show_toast("Камера: %s" % AppSettings.camera_mode_label())


func _refresh_cam_btn() -> void:
	if _cam_btn:
		_cam_btn.text = "Камера · %s" % AppSettings.camera_mode_label()


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_pointer_down = true
		_pointer_start = event.position
		_did_drag = false
		_touch_move = false
		return
	if not _pointer_down:
		return
	_pointer_down = false
	if not _joystick_blocks_touch():
		_player.set_touch_dir(Vector2.ZERO)
	if _did_drag and _touch_move:
		return
	_on_tap(event.position)


func _on_joystick_dir(dir: Vector2) -> void:
	if _player:
		_player.set_touch_dir(dir)


func _joystick_blocks_touch() -> bool:
	return _joystick != null and _joystick.visible


func _sync_joystick_visibility() -> void:
	if _joystick == null:
		return
	var want := DisplayServer.is_touchscreen_available() \
		and not (_device != null and _device.visible) \
		and not (_dialog != null and _dialog.visible)
	if _joystick.visible == want:
		return
	_joystick.visible = want
	if not want and _player:
		_player.set_touch_dir(Vector2.ZERO)


func _handle_drag(event: InputEventScreenDrag) -> void:
	if not _pointer_down:
		return
	if _device.visible:
		_device.handle_drag(event.relative)
		_did_drag = true
		return
	if _dialog.visible:
		return
	if _joystick_blocks_touch():
		if event.position.distance_to(_pointer_start) > 22.0:
			_did_drag = true
		return
	if event.position.distance_to(_pointer_start) > 22.0:
		_did_drag = true
		_touch_move = true
		var dir := event.relative
		if dir.length() > 0.1:
			_player.set_touch_dir(dir.normalized())


func _on_tap(screen_pos: Vector2) -> void:
	var grow := UiFit.touch_grow()
	if _device.visible:
		_device.handle_tap(screen_pos)
		return
	if _dialog.visible:
		_handle_dialog_tap(screen_pos)
		return
	if _menu_btn.get_global_rect().grow(grow).has_point(screen_pos):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		return
	if _cam_btn.get_global_rect().grow(grow).has_point(screen_pos):
		_cycle_camera()
		return
	if _device_btn.get_global_rect().grow(grow).has_point(screen_pos):
		_device.open_device()
		return

	var hit := _raycast_world(screen_pos)
	# NPC приоритетнее места
	var nearest_npc: Node3D = null
	var nearest_npc_d := 99999.0
	for npc in _npcs:
		var d: float = _xz_distance(npc.global_position, _player.global_position)
		if d <= float(npc.talk_radius) + 24.0 and d < nearest_npc_d:
			nearest_npc = npc
			nearest_npc_d = d
	if nearest_npc:
		var hit_npc := hit.get("npc") as Node3D
		if hit_npc == nearest_npc or nearest_npc_d <= float(nearest_npc.talk_radius):
			_open_npc_dialog(nearest_npc)
			return
		if nearest_npc.has_method("contains_xz") and hit.has("point"):
			if nearest_npc.contains_xz(hit["point"]):
				_open_npc_dialog(nearest_npc)
				return

	if GameState.has_active_case():
		var place_id := ""
		if hit.has("place"):
			var place_node: Node3D = hit["place"]
			if _xz_distance(place_node.global_position, _player.global_position) <= CATCH_RADIUS:
				place_id = str(place_node.place_id)
		if place_id.is_empty():
			for place in _places:
				if _xz_distance(place.global_position, _player.global_position) <= CATCH_RADIUS:
					place_id = str(place.place_id)
					break
		if not place_id.is_empty():
			_try_catch_at(place_id)
			return
	_show_toast("Подойди ближе к человеку или месту.")


func _raycast_world(screen_pos: Vector2) -> Dictionary:
	var cam: Camera3D = null
	if _cams and _cams.has_method("current_camera"):
		cam = _cams.current_camera()
	if cam == null:
		return {}
	var from := cam.project_ray_origin(screen_pos)
	var dir := cam.project_ray_normal(screen_pos)
	var to := from + dir * 5000.0
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result := space.intersect_ray(query)
	if result.is_empty():
		# Точка на плоскости Y=0
		if absf(dir.y) > 0.0001:
			var t := -from.y / dir.y
			if t > 0.0:
				return {"point": from + dir * t}
		return {}
	var out := {"point": result.position, "collider": result.collider}
	var collider: Object = result.collider
	if collider is Area3D:
		var area := collider as Area3D
		if area.has_meta("npc"):
			out["npc"] = area.get_meta("npc")
		elif area.has_meta("place"):
			out["place"] = area.get_meta("place")
	# Подъём по родителям на случай StaticBody
	var node: Node = collider as Node
	while node:
		if node.has_meta("npc"):
			out["npc"] = node.get_meta("npc")
			break
		if node.has_meta("place"):
			out["place"] = node.get_meta("place")
			break
		node = node.get_parent()
	return out


func _xz_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func _open_npc_dialog(npc: Node3D) -> void:
	_talk_npc = npc
	if GameState.is_case_closed(npc.case_id):
		_show_simple_dialog(npc.display_name, "Спасибо. Теперь в квартале снова тише.")
		return
	if GameState.has_active_case() and GameState.active_case_id != npc.case_id:
		_show_simple_dialog(npc.display_name, "Ты уже разбираешь другое дело. Сначала закончи его аппаратом.")
		return
	if GameState.active_case_id == npc.case_id:
		_show_simple_dialog(npc.display_name, "Ну как? Поймай волны аппаратом по кварталу и скажи, кто виноват.")
		return

	var case_data := CaseCatalog.by_id(npc.case_id)
	var intake: Dictionary = case_data.get("intake", {})
	_dialog_hits.clear()
	_dialog.visible = true
	_dialog_title.text = str(intake.get("client_name", npc.display_name))
	_dialog_body.text = str(intake.get("speech", case_data.get("brief", "")))
	_layout_dialog(true)


func _show_simple_dialog(title: String, body: String) -> void:
	_talk_npc = null
	_dialog_hits.clear()
	_dialog.visible = true
	_dialog_title.text = title
	_dialog_body.text = body
	_layout_dialog(false)


func _layout_dialog(with_choices: bool) -> void:
	var panel := _dialog.get_node("Panel") as Panel
	var m := UiFit.margins(get_viewport())
	panel.position = Vector2(m.position.x + 24.0, m.position.y + 40.0)
	panel.size = Vector2(m.size.x - 48.0, 280.0 if with_choices else 220.0)
	_dialog_title.position = Vector2(16, 14)
	_dialog_title.size = Vector2(panel.size.x - 32, 30)
	_dialog_body.position = Vector2(16, 50)
	_dialog_body.size = Vector2(panel.size.x - 32, 110.0)

	for child in panel.get_children():
		if child is ColorRect:
			child.queue_free()
	_dialog_hits.clear()

	if with_choices:
		var decline := _dialog_button(panel, "Спасибо, откажусь", Color(0.92, 0.72, 0.68), "decline")
		var accept := _dialog_button(panel, "Конечно, я вам помогу", Color(0.62, 0.86, 0.55), "accept")
		var y := panel.size.y - 70.0
		var w := (panel.size.x - 44.0) * 0.5
		decline.position = Vector2(16, y)
		decline.size = Vector2(w, 54)
		accept.position = Vector2(28 + w, y)
		accept.size = Vector2(w, 54)
	else:
		var ok := _dialog_button(panel, "Понятно", Color(0.86, 0.93, 0.98), "close")
		ok.position = Vector2(16, panel.size.y - 70.0)
		ok.size = Vector2(panel.size.x - 32, 54)


func _dialog_button(panel: Panel, text: String, color: Color, action: String) -> ColorRect:
	var btn := ColorRect.new()
	btn.color = color
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", INK)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(lbl)
	panel.add_child(btn)
	_dialog_hits.append({"node": btn, "action": action})
	return btn


func _handle_dialog_tap(screen_pos: Vector2) -> void:
	var grow := UiFit.touch_grow()
	for hit in _dialog_hits:
		var node: Control = hit["node"]
		if node.get_global_rect().grow(grow).has_point(screen_pos):
			var action := str(hit["action"])
			_dialog.visible = false
			if action == "accept" and _talk_npc:
				GameState.start_case(_talk_npc.case_id)
				_show_toast("Дело принято. Ходи по кварталу и лови волны у мест.")
			elif action == "decline":
				_show_toast("Может, позже.")
			_talk_npc = null
			return


func _try_catch_at(place_id: String) -> void:
	var case_data := GameState.current_case()
	for event in case_data.get("events", []):
		if str(event["place_id"]) != place_id:
			continue
		var eid := str(event["id"])
		if GameState.is_event_caught(eid):
			continue
		GameState.catch_event(eid)
		var kind: SoundCatalog.Kind = event["kind"]
		_spawn_wave(MapLayout.to_3d(MapLayout.pos_of(place_id), 4.0), SoundCatalog.color(kind))
		_show_toast("Поймано: %s · %s" % [event["time"], SoundCatalog.wave_name(kind)])
		if GameState.is_case_ready():
			_show_toast("Улик достаточно. Открой аппарат и сделай вывод.")
		return
	_show_toast("Здесь больше нечего ловить для текущего дела.")


func _on_accused(suspect_id: String) -> void:
	if not GameState.is_case_ready():
		return
	var ok := suspect_id == str(GameState.current_case().get("correct", ""))
	GameState.start_ending(ok, suspect_id)
	_device.close_device()
	var ending := EndingScene.instantiate()
	_ui.add_child(ending)
	ending.finished.connect(_on_ending_finished)


func _on_ending_finished(_ok: bool) -> void:
	_show_toast("Можешь снова гулять по кварталу.")
	_refresh_hint()


func _spawn_wave(world_pos: Vector3, color: Color) -> void:
	var wave := Node3D.new()
	wave.set_script(WaveScript)
	wave.position = world_pos
	wave.color = color
	wave.max_radius = 160.0
	wave.lifetime = 1.0
	_waves.add_child(wave)


func _refresh_hint() -> void:
	if _hint == null:
		return
	if GameState.has_active_case():
		var c := GameState.current_case()
		var caught := GameState.caught_count()
		var need := GameState.VOTE_READY_COUNT
		if caught >= need:
			_hint.text = "%s · %d волн · можно голосовать" % [c.get("title", "Дело"), caught]
		else:
			_hint.text = "%s · %d/%d волн для вывода" % [c.get("title", "Дело"), caught, need]
	else:
		_hint.text = "Квартал · подойди к жителю с жёлтой точкой"


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	if _toast_tween and _toast_tween.is_running():
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(2.5)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.4)


func _apply_safe_ui() -> void:
	if _hint == null:
		return
	var m := UiFit.margins(get_viewport())
	var vp := get_viewport().get_visible_rect()
	var right_pad := vp.size.x - m.end.x
	_hint.position = Vector2(m.position.x + 10, m.position.y + 4)
	_hint.size = Vector2(420, 40)
	_menu_btn.position = Vector2(vp.size.x - 150 - right_pad, m.position.y)
	_menu_btn.size = Vector2(130, 40)
	_cam_btn.position = Vector2(vp.size.x - 210 - right_pad, m.position.y + 42)
	_cam_btn.size = Vector2(190, 36)
	_refresh_cam_btn()
	var tablet_size := Vector2(100.0, 124.0)
	var bottom_pad := vp.size.y - m.end.y
	_device_btn.position = Vector2(
		vp.size.x - tablet_size.x - 12.0 - right_pad,
		vp.size.y - tablet_size.y - 12.0 - bottom_pad
	)
	_device_btn.size = tablet_size
	_toast.position = Vector2(m.position.x + 24, m.position.y + 90)
	_toast.size = Vector2(m.size.x - 48, 70)
	if _joystick:
		var joy_size := Vector2(200, 200)
		_joystick.size = joy_size
		_joystick.position = Vector2(
			m.position.x + 12.0,
			m.end.y - joy_size.y - 10.0
		)
		_sync_joystick_visibility()
	if _dialog.visible:
		_layout_dialog(not _dialog_hits.is_empty() and str(_dialog_hits[0].get("action", "")) != "close")
