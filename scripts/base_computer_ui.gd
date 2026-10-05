extends Control

## Компьютер базы: разбор уже найденных волн (ловить — на местах города).

signal closed
signal open_verdict

const INK := Color(0.16, 0.11, 0.08)
const PAPER := Color(0.98, 0.94, 0.86)

var _hits: Array[Dictionary] = []
var _title: Label
var _hint: Label
var _list: VBoxContainer
var _scroll: ScrollContainer


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build()
	get_viewport().size_changed.connect(_apply_layout)


func open_computer() -> void:
	visible = true
	modulate.a = 0.0
	_refresh()
	_apply_layout()
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.25)


func close_computer() -> void:
	visible = false
	closed.emit()


func handle_tap(screen_pos: Vector2) -> bool:
	if not visible:
		return false
	var grow := UiFit.touch_grow()
	for hit in _hits:
		var node: Control = hit["node"]
		if node.get_global_rect().grow(grow).has_point(screen_pos):
			var action := str(hit["action"])
			if action == "close":
				close_computer()
			elif action == "verdict":
				open_verdict.emit()
			return true
	return true


func handle_drag(relative: Vector2) -> void:
	if visible and _scroll:
		_scroll.scroll_vertical -= int(relative.y)


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.12, 0.16, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var panel := Panel.new()
	panel.name = "Panel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.set_corner_radius_all(12)
	style.set_border_width_all(2)
	style.border_color = INK
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	_title = Label.new()
	_title.text = "Компьютер базы"
	_title.add_theme_font_size_override("font_size", 26)
	_title.add_theme_color_override("font_color", INK)
	panel.add_child(_title)

	_hint = Label.new()
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.add_theme_font_size_override("font_size", 18)
	_hint.add_theme_color_override("font_color", Color(0.28, 0.2, 0.14))
	panel.add_child(_hint)

	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(_scroll)

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scroll.add_child(_list)


func _refresh() -> void:
	_hits.clear()
	for child in _list.get_children():
		child.queue_free()

	if not GameState.has_active_case():
		_hint.text = "Нет активного дела. Поговори с жителем, потом ищи волны по местам квартала."
		_add_row("Закрыть", Color(0.86, 0.93, 0.98), "close", "")
		return

	var case_data := GameState.current_case()
	var caught_n := GameState.caught_count()
	var places_n := GameState.visited_place_count()
	_hint.text = "%s · улик %d · мест %d/%d. Здесь — таймлайн найденного. Лови волны на улице." % [
		case_data.get("title", "Дело"),
		caught_n,
		places_n,
		GameState.VOTE_MIN_PLACES,
	]

	var rows: Array = []
	for event in case_data.get("events", []):
		if GameState.is_event_caught(str(event["id"])):
			rows.append(event)
	rows.sort_custom(func(a, b): return str(a.get("time", "")) < str(b.get("time", "")))

	var key_time := str(case_data.get("key_time", ""))
	if rows.is_empty():
		var empty := Label.new()
		empty.text = "Пока пусто. Обойди места квартала (двор, парк, калитка…) и поймай волны там."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.add_theme_font_size_override("font_size", 17)
		empty.add_theme_color_override("font_color", Color(0.4, 0.3, 0.22))
		_list.add_child(empty)
	else:
		for event in rows:
			var kind: SoundCatalog.Kind = event["kind"]
			var mark := "★ ключ" if str(event.get("time", "")) == key_time else "· спорно"
			var caption := "%s · %s · %s\n%s\n[%s]" % [
				event["time"], event.get("place", ""), SoundCatalog.wave_name(kind), event.get("note", ""), mark
			]
			var bg := Color(0.95, 0.85, 0.45) if str(event.get("time", "")) == key_time else Color(0.78, 0.88, 0.95)
			_add_row(caption, bg, "noop", "")

	if GameState.is_case_ready():
		_hint.text = "Улик и мест достаточно. Можно делать вывод."
		_add_row("Открыть аппарат · вердикт", Color(0.95, 0.82, 0.45), "verdict", "")
	elif caught_n >= GameState.VOTE_READY_COUNT:
		_hint.text = "Улик %d, но нужно посетить ещё места (сейчас %d/%d)." % [
			caught_n, places_n, GameState.VOTE_MIN_PLACES
		]
	_add_row("Закрыть", Color(0.86, 0.93, 0.98), "close", "")


func _add_row(text: String, bg: Color, action: String, arg: String) -> void:
	_list.add_child(_row(text, bg, action, arg))


func _row(text: String, bg: Color, action: String, arg: String) -> ColorRect:
	var btn := ColorRect.new()
	btn.custom_minimum_size = Vector2(100, 64)
	btn.color = bg
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 12
	label.offset_right = -12
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", INK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(label)
	_hits.append({"node": btn, "action": action, "arg": arg})
	return btn


func _apply_layout() -> void:
	if _title == null:
		return
	var panel := get_node("Panel") as Panel
	var m := UiFit.margins(get_viewport())
	panel.position = Vector2(m.position.x + 24.0, m.position.y + 48.0)
	panel.size = Vector2(m.size.x - 48.0, mini(m.size.y - 96.0, 520.0))
	_title.position = Vector2(16, 12)
	_title.size = Vector2(panel.size.x - 32, 32)
	_hint.position = Vector2(16, 48)
	_hint.size = Vector2(panel.size.x - 32, 56)
	_scroll.position = Vector2(16, 110)
	_scroll.size = Vector2(panel.size.x - 32, panel.size.y - 126)
	_list.custom_minimum_size = Vector2(_scroll.size.x, 0)
