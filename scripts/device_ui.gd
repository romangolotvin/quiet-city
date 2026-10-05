extends Control

## Планшет: журнал улик и вердикт (ловлю волны — на компьютере базы).

signal closed
signal accused(suspect_id: String)

const INK := Color(0.16, 0.11, 0.08)
const PAPER := Color(0.98, 0.94, 0.86)
const ROW := Color(0.86, 0.78, 0.64, 0.7)

var _case: Dictionary = {}
var _hits: Array[Dictionary] = []
var _title: Label
var _hint: Label
var _log_box: VBoxContainer
var _suspects: VBoxContainer
var _scroll: ScrollContainer


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build()
	get_viewport().size_changed.connect(_apply_layout)


func open_device() -> void:
	_case = GameState.current_case()
	visible = true
	modulate.a = 0.0
	_refresh()
	_apply_layout()
	var panel := get_node_or_null("Panel") as Control
	if panel:
		panel.position.y += 28.0
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, 0.28)
	if panel:
		tw.parallel().tween_property(panel, "position:y", panel.position.y - 28.0, 0.32)


func close_device() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.18)
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
				close_device()
			elif action == "accuse":
				accused.emit(str(hit["arg"]))
			return true
	return true # съедаем тап, пока аппарат открыт


func handle_drag(relative: Vector2) -> void:
	if visible and _scroll:
		_scroll.scroll_vertical -= int(relative.y)


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.1, 0.08, 0.55)
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

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 10)
	_scroll.add_child(col)

	var log_h := Label.new()
	log_h.text = "Журнал улик"
	log_h.add_theme_font_size_override("font_size", 20)
	log_h.add_theme_color_override("font_color", INK)
	col.add_child(log_h)

	_log_box = VBoxContainer.new()
	_log_box.add_theme_constant_override("separation", 8)
	col.add_child(_log_box)

	var sus_h := Label.new()
	sus_h.text = "Вывод"
	sus_h.add_theme_font_size_override("font_size", 20)
	sus_h.add_theme_color_override("font_color", INK)
	col.add_child(sus_h)

	_suspects = VBoxContainer.new()
	_suspects.add_theme_constant_override("separation", 8)
	col.add_child(_suspects)

	var close_btn := _make_row("Закрыть планшет", Color(0.9, 0.86, 0.78), "close", "")
	panel.add_child(close_btn)
	close_btn.name = "CloseBtn"


func _make_row(text: String, bg: Color, action: String, arg: String) -> ColorRect:
	var row := ColorRect.new()
	row.color = bg
	row.custom_minimum_size = Vector2(0, 64)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.offset_left = 10
	lbl.offset_right = -10
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.add_theme_color_override("font_color", INK)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(lbl)
	_hits.append({"node": row, "action": action, "arg": arg})
	return row


func _refresh() -> void:
	var kept: Array[Dictionary] = []
	for h in _hits:
		if str(h["action"]) == "close":
			kept.append(h)
	_hits = kept
	for c in _log_box.get_children():
		c.queue_free()
	for c in _suspects.get_children():
		c.queue_free()

	_title.text = str(_case.get("title", "Планшет"))
	if not GameState.has_active_case():
		_hint.text = "Дело не взято. Подойди к жителю с жёлтой точкой."
		return

	var events: Array = _case.get("events", [])
	var need := GameState.VOTE_READY_COUNT
	_hint.text = "Журнал и вердикт. Волны — на базе. Поймано %d/%d. %s" % [
		GameState.caught_count(), need, _case.get("ask", "")
	]

	var any := false
	for event in events:
		if not GameState.is_event_caught(str(event["id"])):
			continue
		any = true
		var kind: SoundCatalog.Kind = event["kind"]
		var block := Label.new()
		block.text = "%s · %s · %s\n%s" % [event["time"], SoundCatalog.wave_name(kind), event["place"], event["note"]]
		block.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		block.add_theme_font_size_override("font_size", 17)
		block.add_theme_color_override("font_color", INK)
		_log_box.add_child(block)
	if not any:
		var empty := Label.new()
		empty.text = "Пока пусто. Вернись на базу к компьютеру, чтобы поймать волны."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.add_theme_font_size_override("font_size", 17)
		empty.add_theme_color_override("font_color", Color(0.4, 0.3, 0.22))
		_log_box.add_child(empty)

	if GameState.is_case_ready():
		for suspect in _case.get("suspects", []):
			var caption := "%s\n%s" % [suspect["label"], suspect.get("hint", "")]
			var row := _make_row(caption, ROW, "accuse", str(suspect["id"]))
			_suspects.add_child(row)
	else:
		var wait := Label.new()
		wait.text = "Когда поймаешь любые %d волны, здесь появятся варианты ответа." % need
		wait.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		wait.add_theme_font_size_override("font_size", 17)
		wait.add_theme_color_override("font_color", Color(0.4, 0.3, 0.22))
		_suspects.add_child(wait)


func _apply_layout() -> void:
	var panel := get_node_or_null("Panel") as Panel
	if panel == null:
		return
	var m := UiFit.margins(get_viewport())
	panel.position = Vector2(m.position.x + 20.0, m.position.y + 16.0)
	panel.size = Vector2(m.size.x - 40.0, m.size.y - 32.0)
	_title.position = Vector2(18, 14)
	_title.size = Vector2(panel.size.x - 36, 34)
	_hint.position = Vector2(18, 50)
	_hint.size = Vector2(panel.size.x - 36, 48)
	_scroll.position = Vector2(18, 104)
	_scroll.size = Vector2(panel.size.x - 36, panel.size.y - 180)
	var close_btn := panel.get_node_or_null("CloseBtn") as ColorRect
	if close_btn:
		close_btn.position = Vector2(18, panel.size.y - 72)
		close_btn.size = Vector2(panel.size.x - 36, 56)
