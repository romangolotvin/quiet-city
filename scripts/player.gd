extends CharacterBody2D

## Игрок в квартале: вид сверху.

const SPEED := 240.0
const INK := Color(0.16, 0.11, 0.08)

var facing := Vector2.DOWN
var _touch_dir := Vector2.ZERO


func _physics_process(_delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1
	if dir == Vector2.ZERO:
		dir = _touch_dir
	if dir != Vector2.ZERO:
		facing = dir.normalized()
		velocity = facing * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	queue_redraw()


func set_touch_dir(dir: Vector2) -> void:
	_touch_dir = dir


func _draw() -> void:
	# Простой человечек сверху.
	draw_circle(Vector2(0, 4), 16.0, Color(0.25, 0.45, 0.75))
	draw_circle(Vector2(0, -10), 11.0, Color(0.86, 0.72, 0.58))
	draw_circle(Vector2(0, -10), 11.0, INK, false, 2.0)
	var nose := facing.normalized() * 10.0
	draw_circle(Vector2(0, -10) + nose * 0.35, 3.0, INK)
