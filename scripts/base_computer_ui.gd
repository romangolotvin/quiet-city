extends Control

## Компьютер на базе: ловля волн текущего дела.

signal closed
signal caught(event_id: String)

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
	var panel := get_node_or_null("Panel") as Control
	if panel:
		panel.position.y += 24.0
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, 0.28)
	if panel:
		tw.parallel().tween_property(panel, "position:y", panel.position.y - 24.0, 0.3)


func close_computer() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.16)
	tw.tween_callback(func() -> void:
		visible = false
		closed.emit()
	)


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
			elif action == "catch":
				caught.emit(str(hit["arg"]))
				_refresh()
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
		_hint.text = "Нет активного дела. Поговори с жителем, затем лови волны здесь."
		_add_row("Закрыть", Color(0.86, 0.93, 0.98), "close", "")
		return

	var case_data := GameState.current_case()
	var caught_n := GameState.caught_count()
	var need := GameState.VOTE_READY_COUNT
	_hint.text = "%s · поймано %d/%d. Выбери запись, чтобы поймать волну." % [
		case_data.get("title", "Дело"), caught_n, need
	]

	var any_left := false
	for event in case_data.get("events", []):
		var eid := str(event["id"])
		if GameState.is_event_caught(eid):
			continue
		any_left = true
		var place_id := str(event["place_id"])
		var place_name := place_id
		if MapLayout.PLACES.has(place_id):
			place_name = str(MapLayout.place(place_id)["name"])
		var kind: SoundCatalog.Kind = event["kind"]
		var caption := "%s · %s\n%s" % [event["time"], place_name, SoundCatalog.wave_name(kind)]
		_add_row(caption, Color(0.72, 0.88, 0.98), "catch", eid)

	if GameState.is_case_ready():
		_hint.text = "Улик достаточно. Значок аппарата справа — сделай вывод."
	elif not any_left:
		_hint.text = "Все доступные волны этого дела уже пойманы."
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
	label.add_theme_font_size_override("font_size", 18)
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
