extends Node2D

const ICON_COLOR := Color(0.93, 0.93, 0.9)
const INK := Color(0.12, 0.13, 0.18)

var kind: SoundCatalog.Kind = SoundCatalog.Kind.FIGHT
var hit_radius: float = 70.0


func setup(p_kind: SoundCatalog.Kind) -> void:
	kind = p_kind
	queue_redraw()


func contains(world_pos: Vector2) -> bool:
	return global_position.distance_to(world_pos) <= hit_radius


func _ready() -> void:
	var tw := create_tween().set_loops()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "scale", Vector2(1.14, 1.14), 0.5)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 28.0, Color(0.12, 0.13, 0.18, 0.92))
	draw_arc(Vector2.ZERO, 30.0, 0.0, TAU, 40, ICON_COLOR, 3.0, true)
	var tri := PackedVector2Array([
		Vector2(0, -16), Vector2(14, 12), Vector2(-14, 12)
	])
	draw_colored_polygon(tri, ICON_COLOR)
	draw_circle(Vector2(0, 6), 2.4, INK)
	draw_line(Vector2(0, -10), Vector2(0, 2), INK, 2.6, true)
