extends CharacterBody3D

## Игрок в 3D-квартале: движение по XZ.

const SPEED := 240.0
const GRAVITY := 40.0

var facing := Vector3(0, 0, 1)
var _touch_dir := Vector2.ZERO
var _camera_mode := 0
var _move_basis: Basis = Basis.IDENTITY
var _mesh: MeshInstance3D
var _input_locked := false


func _ready() -> void:
	_build_mesh()


func _build_mesh() -> void:
	_mesh = MeshInstance3D.new()
	_mesh.name = "BodyMesh"
	var capsule := CapsuleMesh.new()
	capsule.radius = 12.0
	capsule.height = 36.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.25, 0.45, 0.75)
	capsule.material = mat
	_mesh.mesh = capsule
	_mesh.position = Vector3(0, 18, 0)
	add_child(_mesh)

	var head := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 9.0
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.86, 0.72, 0.58)
	sphere.material = skin
	head.mesh = sphere
	head.position = Vector3(0, 34, 0)
	_mesh.add_child(head)


func set_touch_dir(dir: Vector2) -> void:
	_touch_dir = dir


func set_camera_mode(mode: int) -> void:
	_camera_mode = mode
	if _mesh:
		_mesh.visible = mode != AppSettings.CAMERA_FIRST


func set_move_basis(basis: Basis) -> void:
	_move_basis = basis


func set_input_locked(locked: bool) -> void:
	_input_locked = locked
	if locked:
		velocity = Vector3.ZERO
		_touch_dir = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	# Держим игрока на плоскости квартала — без падений сквозь низкополигональный пол.
	velocity.y = 0.0
	global_position.y = 0.0

	if _input_locked:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		global_position.y = 0.0
		return

	var dir2 := Vector2.ZERO
	var analog := false
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir2.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir2.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir2.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir2.x += 1
	if dir2 == Vector2.ZERO:
		dir2 = _touch_dir
		analog = true

	var move := Vector3.ZERO
	if dir2 != Vector2.ZERO:
		var strength := 1.0
		if analog:
			strength = clampf(dir2.length(), 0.0, 1.0)
		dir2 = dir2.normalized()
		if _camera_mode == AppSettings.CAMERA_TOP:
			move = Vector3(dir2.x, 0.0, dir2.y)
		else:
			var forward := -_move_basis.z
			forward.y = 0.0
			if forward.length_squared() < 0.0001:
				forward = Vector3(0, 0, 1)
			else:
				forward = forward.normalized()
			var right := _move_basis.x
			right.y = 0.0
			if right.length_squared() < 0.0001:
				right = Vector3(1, 0, 0)
			else:
				right = right.normalized()
			# dir2.y: вверх стика = вперёд (−Z экрана в 2D джойстике было −Y)
			move = (right * dir2.x + forward * (-dir2.y)).normalized()
		facing = move
		velocity.x = move.x * SPEED * strength
		velocity.z = move.z * SPEED * strength
		rotation.y = atan2(facing.x, facing.z)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
	global_position.y = 0.0
