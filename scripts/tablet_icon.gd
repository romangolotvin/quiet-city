extends Control

## Значок планшета / аппарата волн в углу экрана.

const BODY := Color(0.22, 0.28, 0.34)
const FRAME := Color(0.12, 0.14, 0.16)
const SCREEN := Color(0.72, 0.88, 0.92)
const WAVE := Color(0.28, 0.55, 0.62)
const GLOW := Color(1.0, 0.97, 0.9, 0.55)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	# Мягкая подложка, чтобы иконка читалась на карте.
	draw_rect(r.grow(-2.0), GLOW, true)

	var pad_x := size.x * 0.12
	var pad_y := size.y * 0.12
	var body := Rect2(pad_x, pad_y * 0.85, size.x - pad_x * 2.0, size.y - pad_y * 1.7)
	draw_rect(body, BODY, true)
	draw_rect(body, FRAME, false, 3.0)

	var screen := Rect2(
		body.position.x + body.size.x * 0.1,
		body.position.y + body.size.y * 0.12,
		body.size.x * 0.8,
		body.size.y * 0.62
	)
	draw_rect(screen, SCREEN, true)

	# Три дуги «волн» на экране.
	var cx := screen.position.x + screen.size.x * 0.5
	var cy := screen.position.y + screen.size.y * 0.62
	for i in range(3):
		var rad := screen.size.x * (0.12 + float(i) * 0.14)
		draw_arc(Vector2(cx, cy), rad, -PI * 0.85, -PI * 0.15, 18, WAVE, 2.5)

	# Нижняя кнопка планшета.
	var btn_r := mini(size.x, size.y) * 0.06
	draw_circle(Vector2(body.position.x + body.size.x * 0.5, body.end.y - body.size.y * 0.12), btn_r, FRAME)
