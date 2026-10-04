extends Node

signal changed

const PATH := "user://settings.cfg"

var music_enabled := true
var auto_check_updates := true


func _ready() -> void:
	load_settings()
	call_deferred("_apply_music")


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	music_enabled = bool(cfg.get_value("audio", "music_enabled", true))
	auto_check_updates = bool(cfg.get_value("updates", "auto_check", true))


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music_enabled", music_enabled)
	cfg.set_value("updates", "auto_check", auto_check_updates)
	cfg.save(PATH)
	changed.emit()


func set_music_enabled(value: bool) -> void:
	music_enabled = value
	_apply_music()
	save_settings()


func set_auto_check_updates(value: bool) -> void:
	auto_check_updates = value
	save_settings()


func _apply_music() -> void:
	if CalmMusic and CalmMusic.has_method("set_music_enabled"):
		CalmMusic.set_music_enabled(music_enabled)
