extends Node3D

## Простой интерьер: стены + выход. Игрок телепортируется внутрь.

signal exited

const WALL := Color(0.82, 0.76, 0.68)
const FLOOR := Color(0.55, 0.45, 0.35)

var place_id := ""
var _exit_pos := Vector3.ZERO
var _player: Node3D
var _active := false


func setup(id: String, at: Vector3, player: Node3D) -> void:
	place_id = id
	_player = player
	_exit_pos = at + Vector3(0, 0, 70)
	_build(at)
	visible = false


func enter() -> void:
	visible = true
	_active = true
	if _player:
		_player.global_position = global_position + Vector3(0, 0, 10)


func is_active() -> bool:
	return _active


func try_exit_near_player() -> bool:
	if not _active or _player == null:
		return false
	if _player.global_position.distance_to(global_position + Vector3(0, 0, 55)) < 40.0:
		_exit()
		return true
	return false


func _exit() -> void:
	_active = false
	visible = false
	if _player:
		_player.global_position = _exit_pos
	exited.emit()


func _build(at: Vector3) -> void:
	global_position = at + Vector3(0, 0, -40)
	_box(Vector3(0, 1, 0), Vector3(120, 2, 100), FLOOR)
	_box(Vector3(0, 40, -50), Vector3(120, 80, 8), WALL)
	_box(Vector3(-60, 40, 0), Vector3(8, 80, 100), WALL)
	_box(Vector3(60, 40, 0), Vector3(8, 80, 100), WALL)
	_box(Vector3(0, 82, 0), Vector3(128, 8, 108), Color(0.45, 0.35, 0.28))
	# Стол / улика-зона
	_box(Vector3(0, 14, -20), Vector3(40, 28, 28), Color(0.4, 0.3, 0.22))
	_box(Vector3(0, 30, -20), Vector3(24, 10, 6), Color(0.3, 0.55, 0.8))
	# Проём выхода
	_box(Vector3(-30, 30, 50), Vector3(20, 60, 6), WALL)
	_box(Vector3(30, 30, 50), Vector3(20, 60, 6), WALL)
	var label := Label3D.new()
	label.text = "Выход →"
	label.font_size = 48
	label.position = Vector3(0, 50, 48)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)


func _box(pos: Vector3, size: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material = mat
	mi.mesh = mesh
	mi.position = pos
	add_child(mi)
	var body := StaticBody3D.new()
	body.position = pos
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	add_child(body)
