extends Node3D

## Три камеры квартала: сверху / 3 лицо / 1 лицо.

signal mode_changed(mode: int)

const TOP_HEIGHT := 780.0
const THIRD_DIST := 150.0
const THIRD_HEIGHT := 78.0
const FIRST_HEIGHT := 46.0

var _player: Node3D
var _cam_top: Camera3D
var _cam_third: Camera3D
var _cam_first: Camera3D
var _mode := 0
var _cutscene_cam: Camera3D
var _cutscene_active := false


func setup(player: Node3D) -> void:
	_player = player
	_cam_top = _make_cam("CamTop")
	_cam_third = _make_cam("CamThird")
	_cam_first = _make_cam("CamFirst")
	_cutscene_cam = _make_cam("CamCutscene")
	_cutscene_cam.current = false
	set_mode(AppSettings.camera_mode, false)


func _make_cam(cam_name: String) -> Camera3D:
	var cam := Camera3D.new()
	cam.name = cam_name
	cam.current = false
	cam.fov = 55.0
	cam.far = 4000.0
	add_child(cam)
	return cam


func current_camera() -> Camera3D:
	if _cutscene_active:
		return _cutscene_cam
	match _mode:
		AppSettings.CAMERA_THIRD:
			return _cam_third
		AppSettings.CAMERA_FIRST:
			return _cam_first
		_:
			return _cam_top


func get_mode() -> int:
	return _mode


func set_mode(mode: int, persist: bool = true) -> void:
	_mode = clampi(mode, 0, 2)
	if persist:
		AppSettings.set_camera_mode(_mode)
	_apply_current()
	if _player and _player.has_method("set_camera_mode"):
		_player.set_camera_mode(_mode)
	mode_changed.emit(_mode)


func cycle() -> void:
	set_mode((_mode + 1) % 3)


func begin_cutscene() -> Camera3D:
	_cutscene_active = true
	_cam_top.current = false
	_cam_third.current = false
	_cam_first.current = false
	_cutscene_cam.current = true
	# Стартуем из активной игровой камеры.
	var src := _gameplay_camera()
	_cutscene_cam.global_transform = src.global_transform
	return _cutscene_cam


func end_cutscene() -> void:
	_cutscene_active = false
	_apply_current()


func is_cutscene() -> bool:
	return _cutscene_active


func _gameplay_camera() -> Camera3D:
	match _mode:
		AppSettings.CAMERA_THIRD:
			return _cam_third
		AppSettings.CAMERA_FIRST:
			return _cam_first
		_:
			return _cam_top


func _apply_current() -> void:
	if _cutscene_active:
		return
	_cam_top.current = _mode == AppSettings.CAMERA_TOP
	_cam_third.current = _mode == AppSettings.CAMERA_THIRD
	_cam_first.current = _mode == AppSettings.CAMERA_FIRST


func _player_pitch() -> float:
	if _player and "pitch" in _player:
		return float(_player.pitch)
	return 0.0


func _process(_delta: float) -> void:
	if _player == null or _cutscene_active:
		return
	var p := _player.global_position
	var face := Vector3(0, 0, 1)
	if _player.has_method("facing_flat"):
		face = _player.facing_flat()
	else:
		face = _player.facing
	if face.length_squared() < 0.0001:
		face = Vector3(0, 0, 1)
	else:
		face = face.normalized()
	var pitch := _player_pitch()
	var look_dir := Vector3(face.x, 0.0, face.z).normalized()
	look_dir.y = tan(pitch)
	look_dir = look_dir.normalized()

	# Сверху
	_cam_top.global_position = p + Vector3(0, TOP_HEIGHT, 0)
	_cam_top.look_at(p + Vector3(0, 0, 0.01), Vector3(0, 0, -1))

	# 3 лицо — за спиной по yaw, высота/дистанция с учётом pitch
	var back := -face
	var pitch_lift := -sin(pitch) * THIRD_DIST * 0.55
	var pitch_pull := cos(pitch)
	_cam_third.global_position = p \
		+ Vector3(back.x, 0, back.z) * (THIRD_DIST * pitch_pull) \
		+ Vector3(0, THIRD_HEIGHT + pitch_lift, 0)
	var third_look := p + Vector3(0, 22, 0) + look_dir * 40.0
	_cam_third.look_at(third_look, Vector3.UP)

	# 1 лицо
	_cam_first.global_position = p + Vector3(0, FIRST_HEIGHT, 0) + face * 8.0
	_cam_first.look_at(_cam_first.global_position + look_dir * 40.0, Vector3.UP)

	if _player.has_method("set_move_basis"):
		_player.set_move_basis(current_camera().global_transform.basis)
