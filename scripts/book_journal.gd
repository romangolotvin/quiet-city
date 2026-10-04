extends Control

const OPEN_TIME := 0.38
const FADE_TIME := 0.22
const CLOSE_LOCK := 0.3
const INK := Color(0.18, 0.14, 0.1)
const INK_SOFT := Color(0.28, 0.22, 0.16)
const ROW_BG := Color(0.86, 0.78, 0.64, 0.55)

signal accused(suspect_id: String)

@onready var closed_icon: Control = $ClosedIcon
@onready var spread: Control = $Spread
@onready var pages: Control = $Spread/Pages
@onready var close_hint: Label = $Spread/Pages/CloseHint
@onready var book_title: Label = $Spread/Pages/LeftPage/BookTitle
@onready var intro: Label = $Spread/Pages/LeftPage/Intro
@onready var obs_scroll: ScrollContainer = $Spread/Pages/LeftPage/ObsScroll
@onready var observations: VBoxContainer = $Spread/Pages/LeftPage/ObsScroll/Observations
@onready var empty_note: Label = $Spread/Pages/LeftPage/EmptyNote
@onready var entries: VBoxContainer = $Spread/Pages/RightPage/Entries
@onready var mystery_hint: Label = $Spread/Pages/RightPage/MysteryHint
@onready var right_scroll: ScrollContainer = $Spread/Pages/RightPage/RightScroll
@onready var suspects: VBoxContainer = $Spread/Pages/RightPage/RightScroll/RightInner/Suspects
@onready var verdict: Label = $Spread/Pages/RightPage/RightScroll/RightInner/Verdict

var is_open := false
var close_lock := 0.0
var solved := false
var _tween: Tween
var _case: Dictionary = {}
var _log: Array[Dictionary] = []
var _suspect_rows: Array[Control] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	spread.visible = false
	pages.modulate.a = 0.0
	_case = GameState.current_case()
	book_title.text = str(_case["title"])
	intro.text = str(_case["brief"])
	closed_icon.pivot_offset = closed_icon.size * 0.5
	_fill_legend()
	_refresh_log()
	_refresh_mystery()


func heard_text(place_id: String) -> String:
	var parts: PackedStringArray = []
	for event in _log:
		if str(event["place_id"]) == place_id:
			var kind: SoundCatalog.Kind = event["kind"]
			parts.append("%s %s. %s" % [event["time"], SoundCatalog.wave_name(kind), event["note"]])
	return " ".join(parts)


func _process(delta: float) -> void:
	close_lock = maxf(close_lock - delta, 0.0)


func contains_closed(screen_pos: Vector2) -> bool:
	return closed_icon.visible and closed_icon.get_global_rect().grow(UiFit.touch_grow()).has_point(screen_pos)


func handle_open_tap(screen_pos: Vector2) -> void:
	if close_lock > 0.0:
		return
	if close_hint.get_global_rect().grow(UiFit.touch_grow()).has_point(screen_pos):
		close_journal()
		return
	if solved:
		return
	for row in _suspect_rows:
		if row.get_global_rect().grow(UiFit.touch_grow()).has_point(screen_pos):
			accused.emit(str(row.get_meta("suspect_id")))
			return


func handle_open_drag(relative: Vector2) -> void:
	if not is_open:
		return
	# На горизонтальном телефоне пальцем листаем обе страницы книги.
	if absf(relative.y) < 0.2:
		return
	obs_scroll.scroll_vertical -= int(relative.y)
	right_scroll.scroll_vertical -= int(relative.y)


func open_journal() -> void:
	if is_open:
		return
	is_open = true
	close_lock = CLOSE_LOCK + OPEN_TIME
	var start := closed_icon.get_global_rect()
	closed_icon.visible = false
	spread.visible = true
	pages.modulate.a = 0.0
	spread.anchor_left = 0.0
	spread.anchor_top = 0.0
	spread.anchor_right = 0.0
	spread.anchor_bottom = 0.0
	spread.position = start.position
	spread.size = start.size
	var vp := get_viewport_rect().size
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(spread, "position", Vector2.ZERO, OPEN_TIME)
	_tween.tween_property(spread, "size", vp, OPEN_TIME)
	_tween.chain().tween_property(pages, "modulate:a", 1.0, FADE_TIME)


func close_journal() -> void:
	if not is_open:
		return
	is_open = false
	var target := closed_icon.get_global_rect()
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(pages, "modulate:a", 0.0, 0.12)
	_tween.tween_callback(_fold_to_icon.bind(target))


func add_observation(event: Dictionary) -> bool:
	for item in _log:
		if item["id"] == event["id"]:
			return false
	_log.append(event)
	_log.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a["time"]) < str(b["time"])
	)
	_refresh_log()
	_refresh_mystery()
	pulse_closed()
	return true


func is_case_ready() -> bool:
	return _log.size() >= _case["events"].size()


func apply_verdict(suspect_id: String) -> bool:
	if not is_case_ready() or solved:
		return false
	var ok := suspect_id == str(_case["correct"])
	if ok:
		solved = true
	return ok


func pulse_closed() -> void:
	if is_open:
		return
	closed_icon.pivot_offset = closed_icon.size * 0.5
	var tw := create_tween()
	tw.tween_property(closed_icon, "scale", Vector2(1.16, 1.16), 0.12)
	tw.tween_property(closed_icon, "scale", Vector2.ONE, 0.2)


func _fold_to_icon(target: Rect2) -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(spread, "position", target.position, OPEN_TIME)
	_tween.tween_property(spread, "size", target.size, OPEN_TIME)
	_tween.chain().tween_callback(_finish_close)


func _finish_close() -> void:
	spread.visible = false
	closed_icon.visible = true


func _fill_legend() -> void:
	for child in entries.get_children():
		child.queue_free()
	for kind in SoundCatalog.all_kinds():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var swatch := ColorRect.new()
		swatch.custom_minimum_size = Vector2(18, 18)
		swatch.color = SoundCatalog.color(kind)
		var title := Label.new()
		title.text = "%s — %s" % [SoundCatalog.wave_name(kind), SoundCatalog.title(kind)]
		title.add_theme_color_override("font_color", INK)
		title.add_theme_font_size_override("font_size", 20)
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(swatch)
		row.add_child(title)
		entries.add_child(row)


func _refresh_log() -> void:
	for child in observations.get_children():
		child.queue_free()
	empty_note.visible = _log.is_empty()
	for event in _log:
		var kind: SoundCatalog.Kind = event["kind"]
		var block := VBoxContainer.new()
		block.add_theme_constant_override("separation", 4)
		var head := HBoxContainer.new()
		head.add_theme_constant_override("separation", 10)
		var swatch := ColorRect.new()
		swatch.custom_minimum_size = Vector2(18, 18)
		swatch.color = SoundCatalog.color(kind)
		var title := Label.new()
		title.text = "%s  %s  ·  %s" % [event["time"], SoundCatalog.wave_name(kind), event["place"]]
		title.add_theme_color_override("font_color", INK)
		title.add_theme_font_size_override("font_size", 22)
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(swatch)
		head.add_child(title)
		var note := Label.new()
		note.text = str(event["note"])
		note.add_theme_color_override("font_color", INK_SOFT)
		note.add_theme_font_size_override("font_size", 18)
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		block.add_child(head)
		block.add_child(note)
		observations.add_child(block)


func _refresh_mystery() -> void:
	for child in suspects.get_children():
		child.queue_free()
	_suspect_rows.clear()
	if not is_case_ready():
		mystery_hint.text = "Когда все знаки записаны, здесь появятся подозреваемые."
		verdict.text = ""
		return
	if solved:
		mystery_hint.text = "Дело закрыто."
		return
	mystery_hint.text = "%s Важное время: %s." % [_case["ask"], _case["key_time"]]
	for suspect in _case["suspects"]:
		var row := ColorRect.new()
		row.custom_minimum_size = Vector2(0, 78)
		row.color = ROW_BG
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.set_meta("suspect_id", suspect["id"])
		var label := Label.new()
		label.text = "%s\n%s" % [suspect["label"], suspect["hint"]]
		label.add_theme_color_override("font_color", INK)
		label.add_theme_font_size_override("font_size", 20)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.offset_left = 10
		label.offset_right = -10
		label.offset_top = 6
		label.offset_bottom = -6
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(label)
		suspects.add_child(row)
		_suspect_rows.append(row)
