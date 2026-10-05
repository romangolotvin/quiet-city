extends Node2D

var color: Color = Color.WHITE
var max_radius: float = 220.0
var lifetime: float = 1.15
var line_width: float = 5.0

var _elapsed: float = 0.0
var _radius: float = 8.0


func _process(delta: float) -> void:
	_elapsed += delta
	var t := clampf(_elapsed / lifetime, 0.0, 1.0)
	_radius = lerpf(8.0, max_radius, t)
	modulate.a = 1.0 - t
	queue_redraw()
	if t >= 1.0:
		queue_free()


func _draw() -> void:
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 72, color, line_width, true)
