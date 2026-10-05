extends CharacterBody3D

## Игрок в 3D-квартале: движение по XZ.

const SPEED := 240.0
## Скорость поворота (рад/с) на полном стике / зажатой A/D.
const TURN_SPEED := 1.6
## Поворот пальцем: радианы на пиксель свайпа.
const LOOK_DRAG_SENS := 0.0022

var facing := Vector3(0, 0, 1)
## Угол взгляда вокруг Y (0 = +Z). Камера 1/3 лица следует за ним.
var yaw := 0.0
var _touch_dir := Vector2.ZERO
var _camera_mode := 0
var _move_basis: Basis = Basis.IDENTITY
var _mesh: Node3D
var _input_locked := false
var _look_yaw_delta := 0.0
var _talk_bob := false


func _ready() -> void:
	_build_mesh()


func _build_mesh() -> void:
	_mesh = Humanoid3D.build(self, "man", 1.05)


func set_talk_bob(enabled: bool) -> void:
	_talk_bob = enabled


func set_touch_dir(dir: Vector2) -> void:
	_touch_dir = dir


func add_look_yaw(delta_rad: float) -> void:
	_look_yaw_delta += delta_rad


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
		_look_yaw_delta = 0.0


func facing_flat() -> Vector3:
	return Vector3(sin(yaw), 0.0, cos(yaw))


func _physics_process(delta: float) -> void:
	# Держим игрока на плоскости квартала — без падений сквозь низкополигональный пол.
	velocity.y = 0.0
	global_position.y = 0.0

	if _input_locked:
		velocity.x = 0.0
		velocity.z = 0.0
		_look_yaw_delta = 0.0
		move_and_slide()
		global_position.y = 0.0
		if _mesh:
			Humanoid3D.animate(_mesh, delta, 0.0, _talk_bob)
		return

	# Свайп взгляда (накопленный за кадр).
	if absf(_look_yaw_delta) > 0.00001:
		yaw -= _look_yaw_delta
		_look_yaw_delta = 0.0

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
	if _camera_mode == AppSettings.CAMERA_TOP:
		if dir2 != Vector2.ZERO:
			var strength := 1.0
			if analog:
				strength = clampf(dir2.length(), 0.0, 1.0)
			dir2 = dir2.normalized()
			move = Vector3(dir2.x, 0.0, dir2.y)
			facing = move
			yaw = atan2(facing.x, facing.z)
			velocity.x = move.x * SPEED * strength
			velocity.z = move.z * SPEED * strength
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		# 1 / 3 лицо: ходьба вперёд/назад + стрейф; look только свайп / ПКМ.
		var strength := 1.0
		if analog and dir2 != Vector2.ZERO:
			strength = clampf(dir2.length(), 0.0, 1.0)
		var forward := facing_flat()
		facing = forward
		var right := Vector3(forward.z, 0.0, -forward.x)
		var forward_axis := 0.0
		var strafe_axis := 0.0
		if analog:
			# Джойстик: Y — вперёд, X — стрейф (без поворота yaw).
			forward_axis = -dir2.y
			strafe_axis = dir2.x
		else:
			if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
				forward_axis -= 1.0
			if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
				forward_axis += 1.0
			if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
				strafe_axis -= 1.0
			if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
				strafe_axis += 1.0
		move = forward * (-forward_axis) + right * strafe_axis
		if move.length_squared() > 0.0001:
			move = move.normalized()
			velocity.x = move.x * SPEED * strength
			velocity.z = move.z * SPEED * strength
		else:
			velocity.x = 0.0
			velocity.z = 0.0

	rotation.y = yaw
	move_and_slide()
	global_position.y = 0.0

	var walk_amt := clampf(Vector2(velocity.x, velocity.z).length() / SPEED, 0.0, 1.0)
	if _mesh:
		Humanoid3D.animate(_mesh, delta, walk_amt, _talk_bob)