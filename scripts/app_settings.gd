extends Node

signal changed

const PATH := "user://settings.cfg"

## Камера квартала: 0 сверху, 1 третье лицо, 2 первое лицо.
const CAMERA_TOP := 0
const CAMERA_THIRD := 1
const CAMERA_FIRST := 2

var music_enabled := true
var auto_check_updates := true
var camera_mode := CAMERA_TOP


func _ready() -> void:
	load_settings()
	call_deferred("_apply_music")


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	music_enabled = bool(cfg.get_value("audio", "music_enabled", true))
	auto_check_updates = bool(cfg.get_value("updates", "auto_check", true))
	camera_mode = int(cfg.get_value("camera", "mode", CAMERA_TOP))
	camera_mode = clampi(camera_mode, CAMERA_TOP, CAMERA_FIRST)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music_enabled", music_enabled)
	cfg.set_value("updates", "auto_check", auto_check_updates)
	cfg.set_value("camera", "mode", camera_mode)
	cfg.save(PATH)
	changed.emit()


func set_music_enabled(value: bool) -> void:
	music_enabled = value
	_apply_music()
	save_settings()


func set_auto_check_updates(value: bool) -> void:
	auto_check_updates = value
	save_settings()


func set_camera_mode(value: int) -> void:
	camera_mode = clampi(value, CAMERA_TOP, CAMERA_FIRST)
	save_settings()


func cycle_camera_mode() -> int:
	set_camera_mode((camera_mode + 1) % 3)
	return camera_mode


func camera_mode_label() -> String:
	match camera_mode:
		CAMERA_THIRD:
			return "3 лицо"
		CAMERA_FIRST:
			return "1 лицо"
		_:
			return "Сверху"


func _apply_music() -> void:
	if CalmMusic and CalmMusic.has_method("set_music_enabled"):
		CalmMusic.set_music_enabled(music_enabled)
