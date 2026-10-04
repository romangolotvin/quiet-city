extends Control

const INK := Color(0.16, 0.11, 0.08)
const CREAM := Color(0.99, 0.96, 0.9)
const EASY := Color(0.62, 0.86, 0.55)
const MEDIUM := Color(0.98, 0.82, 0.38)
const HARD := Color(0.95, 0.55, 0.48)
const PLAY := Color(0.98, 0.9, 0.62)
const ACCENT := Color(0.86, 0.93, 0.98)

var _column: VBoxContainer
var _scroll: ScrollContainer
var _list: VBoxContainer
var _title: Label
var _subtitle: Label
var _hits: Array[Dictionary] = []
var _pointer_down := false
var _pointer_start := Vector2.ZERO
var _did_drag := false
var _screen := "title"
var _pending_update: Dictionary = {}


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_shell()
	_apply_safe_layout()
	_show_title()
	UpdateService.status.connect(_on_update_status)
	UpdateService.update_available.connect(_on_update_available)
	UpdateService.up_to_date.connect(_on_up_to_date)
	UpdateService.update_failed.connect(_on_update_failed)
	UpdateService.download_progress.connect(_on_download_progress)
	if AppSettings.auto_check_updates:
		UpdateService.check_for_updates(true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
		_mark_input_handled()
	elif event is InputEventScreenDrag:
		_handle_drag(event)
		_mark_input_handled()


func _mark_input_handled() -> void:
	var vp := get_viewport()
	if vp:
		vp.set_input_as_handled()


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
	_on_tap(event.position)


func _handle_drag(event: InputEventScreenDrag) -> void:
	if not _pointer_down:
		return
	if event.position.distance_to(_pointer_start) > 18.0:
		_did_drag = true
	_scroll.scroll_vertical -= int(event.relative.y)


func _on_tap(screen_pos: Vector2) -> void:
	var grow := UiFit.touch_grow()
	for hit in _hits:
		var node: Control = hit["node"]
		if node.get_global_rect().grow(grow).has_point(screen_pos):
			_run(str(hit["action"]), str(hit["arg"]))
			return


func _run(action: String, arg: String) -> void:
	match action:
		"play":
			_show_difficulties()
		"settings":
			_show_settings()
		"diff":
			_show_cases(arg)
		"back_diff":
			_show_difficulties()
		"back_title":
			_show_title()
		"case":
			GameState.case_id = arg
			get_tree().change_scene_to_file("res://scenes/intake.tscn")
		"toggle_music":
			AppSettings.set_music_enabled(not AppSettings.music_enabled)
			_show_settings()
		"toggle_auto":
			AppSettings.set_auto_check_updates(not AppSettings.auto_check_updates)
			_show_settings()
		"check_updates":
			_subtitle.text = "Проверяю обновления…"
			UpdateService.check_for_updates(false)
		"do_update":
			_subtitle.text = "Обновляю…"
			UpdateService.start_update()


func _build_shell() -> void:
	_column = VBoxContainer.new()
	_column.set_anchors_preset(Control.PRESET_FULL_RECT)
	_column.alignment = BoxContainer.ALIGNMENT_CENTER
	_column.add_theme_constant_override("separation", 14)
	_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_column)

	_title = Label.new()
	_title.text = "Тихий город"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 56)
	_title.add_theme_color_override("font_color", INK)
	_column.add_child(_title)

	_subtitle = Label.new()
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitle.add_theme_font_size_override("font_size", 22)
	_subtitle.add_theme_color_override("font_color", Color(0.28, 0.2, 0.14))
	_column.add_child(_subtitle)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_scroll.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_column.add_child(_scroll)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_list.alignment = BoxContainer.ALIGNMENT_CENTER
	_list.add_theme_constant_override("separation", 14)
	_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scroll.add_child(_list)


func _apply_safe_layout() -> void:
	if _column == null or _title == null:
		return
	var m := UiFit.margins(get_viewport())
	var compact := UiFit.is_compact(get_viewport())
	var side := 28.0
	_column.offset_left = m.position.x + side
	_column.offset_top = m.position.y + (20.0 if compact else 28.0)
	_column.offset_right = -(get_viewport_rect().size.x - m.end.x) - side
	_column.offset_bottom = -(get_viewport_rect().size.y - m.end.y) - 16.0
	_title.add_theme_font_size_override("font_size", 44 if compact else 58)
	_subtitle.add_theme_font_size_override("font_size", 20 if compact else 24)
	var btn_w := mini(560.0, m.size.x - 40.0)
	_scroll.custom_minimum_size = Vector2(btn_w, mini(m.size.y * 0.55, 420.0))
	_list.custom_minimum_size = Vector2(btn_w, 0.0)
	queue_redraw()


func _show_title() -> void:
	_screen = "title"
	_subtitle.text = "Горизонтальный режим. Версия %s." % UpdateService.current_version()
	_clear_hits()
	_add_button("Играть", PLAY, "play")
	_add_button("Настройки", ACCENT, "settings")
	if not _pending_update.is_empty():
		_add_button("Обновить до %s" % _pending_update.get("version", "?"), EASY, "do_update")
	_scroll.scroll_vertical = 0


func _show_settings() -> void:
	_screen = "settings"
	_subtitle.text = "Версия %s. Музыка, автопроверка и обновления." % UpdateService.current_version()
	_clear_hits()
	var music_label := "Музыка: включена" if AppSettings.music_enabled else "Музыка: выключена"
	_add_button(music_label, PLAY if AppSettings.music_enabled else CREAM, "toggle_music")
	var auto_label := "Автопроверка обновлений: да" if AppSettings.auto_check_updates else "Автопроверка обновлений: нет"
	_add_button(auto_label, ACCENT if AppSettings.auto_check_updates else CREAM, "toggle_auto")
	_add_button("Проверить обновления", MEDIUM, "check_updates")
	if not _pending_update.is_empty():
		var notes := str(_pending_update.get("notes", ""))
		var caption := "Обновить до %s" % _pending_update.get("version", "?")
		if not notes.is_empty():
			caption += "\n%s" % notes
		_add_button(caption, EASY, "do_update")
	_add_button("Назад", CREAM, "back_title")
	_scroll.scroll_vertical = 0


func _show_difficulties() -> void:
	_screen = "diff"
	_subtitle.text = "Выбери сложность. Ситуации внутри — от простых к трудным."
	_clear_hits()
	for diff in CaseCatalog.difficulties():
		var color := CREAM
		match str(diff["id"]):
			"easy":
				color = EASY
			"medium":
				color = MEDIUM
			"hard":
				color = HARD
		var count := CaseCatalog.cases_for(str(diff["id"])).size()
		var caption := "%s\n%s · %d дела" % [diff["title"], diff["blurb"], count]
		_add_button(caption, color, "diff", str(diff["id"]))
	_add_button("Назад", CREAM, "back_title")
	_scroll.scroll_vertical = 0


func _show_cases(diff: String) -> void:
	_screen = "cases"
	var title := "Ситуации"
	for item in CaseCatalog.difficulties():
		if str(item["id"]) == diff:
			title = str(item["title"])
	_subtitle.text = "%s. Нажми ситуацию, чтобы выйти в город." % title
	_clear_hits()
	for case_data in CaseCatalog.cases_for(diff):
		var signs: int = case_data["events"].size()
		var caption := "%s\n%d %s" % [case_data["title"], signs, _signs_word(signs)]
		_add_button(caption, CREAM, "case", str(case_data["id"]))
	_add_button("Назад", CREAM, "back_diff")
	_scroll.scroll_vertical = 0


func _on_update_status(text: String) -> void:
	if _screen == "settings" or _screen == "title":
		_subtitle.text = text


func _on_update_available(info: Dictionary) -> void:
	_pending_update = info
	if _screen == "settings":
		_show_settings()
	elif _screen == "title":
		_show_title()
		_subtitle.text = "Доступно обновление %s" % info.get("version", "")


func _on_up_to_date() -> void:
	_pending_update = {}
	if _screen == "settings":
		_show_settings()
		_subtitle.text = "У тебя последняя версия (%s)." % UpdateService.current_version()


func _on_update_failed(text: String) -> void:
	if _screen == "settings" or _screen == "title":
		_subtitle.text = text


func _on_download_progress(loaded: int, total: int) -> void:
	if total <= 0:
		return
	var pct := int(100.0 * float(loaded) / float(total))
	_subtitle.text = "Скачиваю обновление… %d%%" % pct


func _clear_hits() -> void:
	_hits.clear()
	for child in _list.get_children():
		child.queue_free()


func _add_button(text: String, bg: Color, action: String, arg: String = "") -> void:
	var compact := UiFit.is_compact(get_viewport())
	var btn := ColorRect.new()
	btn.custom_minimum_size = Vector2(_list.custom_minimum_size.x, 76 if compact else 84)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.color = bg
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 16
	label.offset_right = -16
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 24 if compact else 28)
	label.add_theme_color_override("font_color", INK)
	btn.add_child(label)
	_list.add_child(btn)
	_hits.append({"node": btn, "action": action, "arg": arg})


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_safe_layout()


func _signs_word(count: int) -> String:
	var n := count % 100
	if n >= 11 and n <= 14:
		return "знаков"
	match count % 10:
		1:
			return "знак"
		2, 3, 4:
			return "знака"
		_:
			return "знаков"


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.97, 0.88, 0.64))
	var compact := UiFit.is_compact(get_viewport())
	var center := Vector2(size.x * 0.5, 52.0 if compact else 96.0)
	var scale := 0.55 if compact else 1.0
	draw_arc(center, 46 * scale, 0, TAU, 40, Color(0.9, 0.28, 0.28, 0.45), 3, true)
	draw_arc(center, 68 * scale, 0, TAU, 48, Color(0.25, 0.72, 0.4, 0.4), 3, true)
	draw_arc(center, 90 * scale, 0, TAU, 56, Color(0.25, 0.48, 0.92, 0.35), 3, true)
