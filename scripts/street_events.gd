extends Node3D

## Случайные уличные ситуации в квартале.

signal toast(text: String)
signal catch_hint(place_id: String)

var _player: Node3D
var _npcs: Array = []
var _cooldown := 12.0
var _active := false
var _attacker: Node3D = null
var _chase_target: Node3D = null
var _nav_marker: Node3D = null
var _chase_timer := 0.0
var _mode := ""
var _caption := ""
var _ui_btn: Label = null
var _ui_layer: CanvasLayer = null
var _blocked_fn: Callable


func setup(player: Node3D, npcs: Array, ui: CanvasLayer, blocked: Callable) -> void:
	_player = player
	_npcs = npcs
	_ui_layer = ui
	_blocked_fn = blocked
	_cooldown = randf_range(25.0, 45.0)


func is_active() -> bool:
	return _active


func nav_target() -> Node3D:
	if not _active:
		return null
	match _mode:
		"attack":
			return _attacker if is_instance_valid(_attacker) else null
		"chase":
			return _chase_target if is_instance_valid(_chase_target) else null
		"cry", "quarrel", "false":
			return _nav_marker if is_instance_valid(_nav_marker) else null
		_:
			return null


func nav_caption() -> String:
	return _caption if not _caption.is_empty() else "Сюда"


func handle_tap(screen_pos: Vector2) -> bool:
	if not _active or _ui_btn == null or not _ui_btn.visible:
		return false
	if _ui_btn.get_global_rect().grow(UiFit.touch_grow()).has_point(screen_pos):
		_resolve_action()
		return true
	return false


func _process(delta: float) -> void:
	if _player == null:
		return
	if _blocked_fn.is_valid() and bool(_blocked_fn.call()):
		return
	if _active:
		_update_active(delta)
		return
	_cooldown -= delta
	if _cooldown <= 0.0:
		_try_start()


func _try_start() -> void:
	_cooldown = randf_range(50.0, 95.0)
	if not GameState.has_active_case() and randf() < 0.35:
		return
	var roll := randf()
	if roll < 0.22:
		_start_attack()
	elif roll < 0.42:
		_start_cry()
	elif roll < 0.62:
		_start_chase()
	elif roll < 0.8:
		_start_quarrel()
	else:
		_start_false_alarm()


func _start_attack() -> void:
	_mode = "attack"
	_caption = "Опасность"
	_active = true
	_attacker = _make_runner(Color(0.75, 0.25, 0.22))
	_show_action("Увернись!", "Уклонись от нападения")
	toast.emit("К тебе бежит кто-то агрессивный!")


func _start_cry() -> void:
	_mode = "cry"
	_caption = "Крик"
	_active = true
	_chase_timer = 16.0
	var places := ["alley", "park", "market", "embankment"]
	var pid := str(places[randi() % places.size()])
	_set_place_marker(pid)
	_show_action("Беги к крику", "Крик из «%s» — успей!" % pid)
	toast.emit("Крик с другой улицы! Стрелка ведёт к месту.")
	catch_hint.emit(pid)


func _start_chase() -> void:
	_mode = "chase"
	_caption = "Погоня"
	_active = true
	_chase_timer = 12.0
	_chase_target = _make_runner(Color(0.2, 0.2, 0.25))
	_show_action("Догони!", "Тень убегает — догони")
	toast.emit("Тень ускользает по улице!")


func _start_quarrel() -> void:
	_mode = "quarrel"
	_caption = "Сюда"
	_active = true
	_chase_timer = 6.0
	_set_place_marker("plaza")
	_show_action("Слушать", "Постой рядом со спором")
	toast.emit("На площади спор — постой рядом, чтобы услышать.")


func _start_false_alarm() -> void:
	_mode = "false"
	_caption = "Сюда"
	_active = true
	_chase_timer = 8.0
	# Точка шума рядом с игроком — стабильный маркер, не прыгает.
	var offset := Vector3(randf_range(-120, 120), 0, randf_range(-120, 120))
	if offset.length() < 40.0:
		offset = Vector3(80, 0, 40)
	_set_world_marker(_player.global_position + offset)
	_show_action("Проверить", "Громкий шум рядом")
	toast.emit("Громкий шум! Проверь…")


func _set_place_marker(place_id: String) -> void:
	_clear_nav_marker()
	_nav_marker = Node3D.new()
	add_child(_nav_marker)
	_nav_marker.global_position = MapLayout.to_3d(MapLayout.pos_of(place_id), 0.0)


func _set_world_marker(pos: Vector3) -> void:
	_clear_nav_marker()
	_nav_marker = Node3D.new()
	add_child(_nav_marker)
	_nav_marker.global_position = pos


func _clear_nav_marker() -> void:
	if _nav_marker and is_instance_valid(_nav_marker):
		_nav_marker.queue_free()
	_nav_marker = null


func _update_active(delta: float) -> void:
	if _mode == "attack" and _attacker:
		var to_p: Vector3 = _player.global_position - _attacker.global_position
		to_p.y = 0.0
		if to_p.length() > 2.0:
			_attacker.global_position += to_p.normalized() * 220.0 * delta
		if to_p.length() < 28.0:
			_fail_attack()
			return
	if _mode == "chase" and _chase_target:
		_chase_timer -= delta
		var away: Vector3 = _chase_target.global_position - _player.global_position
		away.y = 0.0
		if away.length() > 1.0:
			_chase_target.global_position += away.normalized() * 180.0 * delta
		if away.length() < 40.0:
			_success_chase()
			return
		if _chase_timer <= 0.0:
			_end_event("Тень исчезла.")
			return
	if _mode in ["cry", "quarrel", "false"]:
		_chase_timer -= delta
		if _chase_timer <= 0.0:
			if _mode == "false":
				_end_event("Ложная тревога — только кот.")
			elif _mode == "cry":
				_end_event("Опоздал: крик стих.")
			else:
				_end_event("Спор закончился без тебя.")


func _resolve_action() -> void:
	match _mode:
		"attack":
			_end_event("Увернулся. Квартал снова тих.")
			if SoundFx:
				SoundFx.play_kind(SoundCatalog.Kind.FIGHT)
		"chase":
			# Успех только если близко — иначе просто попытка
			if _chase_target and _player.global_position.distance_to(_chase_target.global_position) < 80.0:
				_success_chase()
			else:
				toast.emit("Ещё далеко — догони!")
		"quarrel":
			if GameState.has_active_case():
				_grant_random_talk()
			_end_event("Услышал обрывки спора.")
			if SoundFx:
				SoundFx.play_kind(SoundCatalog.Kind.TALK)
		"cry":
			toast.emit("Беги к месту крика — лови волну там.")
			_hide_action()
			# оставляем таймер до timeout
		"false":
			_end_event("Пусто. Красная селёдка для журнала.")
		_:
			_end_event("")


func _fail_attack() -> void:
	if GameState.caught_count() > 0 and randf() < 0.55:
		var last: String = GameState.caught_event_ids[GameState.caught_event_ids.size() - 1]
		GameState.caught_event_ids.erase(last)
		GameState.save_progress()
		_end_event("Удар! Одна улика выпала из журнала.")
	else:
		_end_event("Удар! На мгновение всё звенело в ушах.")
	if SoundFx:
		SoundFx.play_kind(SoundCatalog.Kind.FIGHT)


func _success_chase() -> void:
	if GameState.has_active_case():
		_grant_random_dog()
	_end_event("Догонял! В журнале новая улика.")
	if SoundFx:
		SoundFx.play_kind(SoundCatalog.Kind.DOG)


func _grant_random_talk() -> void:
	_grant_uncatched_of_kinds([SoundCatalog.Kind.TALK, SoundCatalog.Kind.FIGHT])


func _grant_random_dog() -> void:
	_grant_uncatched_of_kinds([SoundCatalog.Kind.DOG, SoundCatalog.Kind.FIGHT])


func _grant_uncatched_of_kinds(kinds: Array) -> void:
	if not GameState.has_active_case():
		return
	for event in GameState.current_case().get("events", []):
		var eid := str(event["id"])
		if GameState.is_event_caught(eid):
			continue
		if kinds.has(event["kind"]):
			GameState.catch_event(eid)
			GameState.visit_place(str(event.get("place_id", "")))
			return


func _make_runner(color: Color) -> Node3D:
	var n := Node3D.new()
	add_child(n)
	var offset := Vector3(randf_range(-200, 200), 0, randf_range(-200, 200))
	n.global_position = _player.global_position + offset
	var mi := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 10.0
	capsule.height = 30.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	capsule.material = mat
	mi.mesh = capsule
	mi.position = Vector3(0, 16, 0)
	n.add_child(mi)
	return n


func _show_action(btn: String, toast_text: String) -> void:
	if _ui_layer == null:
		return
	if _ui_btn == null:
		_ui_btn = Label.new()
		_ui_btn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_ui_btn.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_ui_btn.add_theme_font_size_override("font_size", 22)
		_ui_btn.add_theme_color_override("font_color", Color(0.12, 0.08, 0.05))
		_ui_btn.add_theme_color_override("font_outline_color", Color(1, 0.95, 0.7))
		_ui_btn.add_theme_constant_override("outline_size", 5)
		_ui_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ui_layer.add_child(_ui_btn)
	_ui_btn.text = btn
	var vp := get_viewport().get_visible_rect().size
	_ui_btn.size = Vector2(220, 56)
	_ui_btn.position = Vector2(vp.x * 0.5 - 110.0, vp.y - 120.0)
	_ui_btn.visible = true
	toast.emit(toast_text)


func _hide_action() -> void:
	if _ui_btn:
		_ui_btn.visible = false


func _end_event(msg: String) -> void:
	_active = false
	_mode = ""
	_caption = ""
	_hide_action()
	_clear_nav_marker()
	if _attacker and is_instance_valid(_attacker):
		_attacker.queue_free()
	_attacker = null
	if _chase_target and is_instance_valid(_chase_target):
		_chase_target.queue_free()
	_chase_target = null
	if not msg.is_empty():
		toast.emit(msg)
	_cooldown = randf_range(40.0, 80.0)
