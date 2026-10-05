extends Node2D

const GROUND := Color(0.96, 0.88, 0.66)
const ROAD := Color(0.99, 0.97, 0.92)
const LANE := Color(0.95, 0.74, 0.22)
const BLOCK := Color(0.93, 0.8, 0.58)
const WATER := Color(0.36, 0.74, 0.96)

const ROOFS := [
	Color(0.96, 0.45, 0.38),
	Color(0.98, 0.7, 0.28),
	Color(0.4, 0.64, 0.95),
	Color(0.96, 0.52, 0.7),
	Color(0.36, 0.78, 0.7),
	Color(0.98, 0.6, 0.32),
]


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -1600, 4000, 3400), GROUND)
	_draw_blocks()
	_draw_water()
	_draw_roads()
	for id in MapLayout.ids():
		var data := MapLayout.place(id)
		_draw_art(str(data["art"]), data["pos"])
	_draw_street_names()


func _draw_blocks() -> void:
	var n := 0
	for gx in range(-6, 7):
		for gy in range(-5, 6):
			var center := Vector2(gx * 256.0, gy * 256.0)
			if _on_road(center) or _near_place(center):
				continue
			var roof: Color = ROOFS[posmod(n, ROOFS.size())]
			n += 1
			var body := Rect2(center - Vector2(78, 58), Vector2(156, 116))
			draw_rect(body, roof)
			draw_rect(body.grow(-12), roof.lightened(0.16))
			draw_rect(Rect2(center + Vector2(-18, -8), Vector2(16, 12)), Color(0.86, 0.95, 1.0, 0.9))
			draw_rect(Rect2(center + Vector2(8, -8), Vector2(16, 12)), Color(0.86, 0.95, 1.0, 0.9))
			draw_rect(Rect2(center + Vector2(-70, 58), Vector2(140, 10)), BLOCK)


func _draw_roads() -> void:
	for x in [-768.0, -256.0, 256.0, 768.0]:
		draw_rect(Rect2(x - 46.0, -1500.0, 92.0, 3000.0), ROAD)
		draw_line(Vector2(x, -1500), Vector2(x, 1500), LANE, 4.0)
	for y in [-768.0, -256.0, 256.0, 768.0]:
		draw_rect(Rect2(-1900.0, y - 46.0, 3800.0, 92.0), ROAD)
		draw_line(Vector2(-1900, y), Vector2(1900, y), LANE, 4.0)
	for x in [-768.0, -256.0, 256.0, 768.0]:
		for y in [-768.0, -256.0, 256.0, 768.0]:
			draw_rect(Rect2(x - 18, y - 54, 36, 10), Color(0.2, 0.16, 0.12, 0.35))
			draw_rect(Rect2(x - 54, y - 18, 10, 36), Color(0.2, 0.16, 0.12, 0.35))


func _draw_water() -> void:
	draw_rect(Rect2(-1900, 980, 3800, 220), WATER)
	draw_rect(Rect2(-70, 900, 140, 160), Color(0.72, 0.5, 0.28))
	draw_line(Vector2(-1900, 1060), Vector2(1900, 1060), Color(0.8, 0.94, 1.0, 0.75), 8.0)


func _draw_street_names() -> void:
	var font := ThemeDB.fallback_font
	var ink := Color(0.35, 0.26, 0.16, 0.8)
	draw_string(font, Vector2(-180, -276), "Садовая", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ink)
	draw_string(font, Vector2(-180, -788), "Рыночная", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ink)
	draw_string(font, Vector2(270, -180), "Пекарная", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, ink)


func _draw_art(kind: String, at: Vector2) -> void:
	match kind:
		"plaza":
			draw_circle(at, 78, Color(0.98, 0.82, 0.42))
			draw_arc(at, 78, 0, TAU, 40, Color(0.92, 0.5, 0.18), 6, true)
			draw_circle(at, 24, Color(0.42, 0.78, 0.98))
		"bakery":
			draw_rect(Rect2(at + Vector2(-58, -36), Vector2(116, 72)), Color(0.98, 0.55, 0.32))
			draw_rect(Rect2(at + Vector2(-58, -48), Vector2(116, 16)), Color(0.95, 0.3, 0.28))
			draw_rect(Rect2(at + Vector2(-16, -8), Vector2(32, 28)), Color(0.55, 0.82, 0.95))
		"yard":
			draw_rect(Rect2(at + Vector2(-64, -48), Vector2(128, 96)), Color(0.5, 0.84, 0.4))
			draw_line(at + Vector2(-20, -20), at + Vector2(-20, 24), Color(0.35, 0.24, 0.12), 4)
			draw_line(at + Vector2(20, -20), at + Vector2(20, 24), Color(0.35, 0.24, 0.12), 4)
			draw_arc(at + Vector2(0, -8), 22, PI, TAU, 16, Color(0.25, 0.45, 0.7), 3, true)
		"gate":
			draw_rect(Rect2(at + Vector2(-48, -10), Vector2(96, 18)), Color(0.55, 0.34, 0.16))
			draw_rect(Rect2(at + Vector2(-52, -36), Vector2(12, 52)), Color(0.32, 0.2, 0.1))
			draw_rect(Rect2(at + Vector2(40, -36), Vector2(12, 52)), Color(0.32, 0.2, 0.1))
			draw_circle(at + Vector2(28, -30), 4, Color(0.85, 0.7, 0.2))
		"porch":
			draw_rect(Rect2(at + Vector2(-50, -22), Vector2(100, 44)), Color(0.98, 0.64, 0.46))
			draw_rect(Rect2(at + Vector2(-16, -10), Vector2(32, 26)), Color(0.4, 0.24, 0.14))
			draw_rect(Rect2(at + Vector2(-40, 22), Vector2(80, 8)), Color(0.75, 0.58, 0.4))
		"house":
			draw_rect(Rect2(at + Vector2(-46, -28), Vector2(92, 64)), Color(0.4, 0.58, 0.94))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-54, -24), at + Vector2(0, -62), at + Vector2(54, -24)
			]), Color(0.22, 0.36, 0.72))
		"park":
			draw_rect(Rect2(at + Vector2(-80, -70), Vector2(160, 140)), Color(0.46, 0.82, 0.42))
			for offset in [Vector2(-30, -10), Vector2(20, 16), Vector2(-10, 28), Vector2(36, -24)]:
				draw_circle(at + offset, 16, Color(0.2, 0.58, 0.26))
				draw_circle(at + offset + Vector2(0, -8), 11, Color(0.5, 0.86, 0.4))
		"market":
			for i in 3:
				var stall := Rect2(at + Vector2(-54 + i * 36, -16), Vector2(30, 36))
				draw_rect(stall, Color(0.95, 0.45, 0.35) if i != 1 else Color(0.95, 0.78, 0.28))
				draw_colored_polygon(PackedVector2Array([
					stall.position + Vector2(-4, 0),
					stall.position + Vector2(15, -16),
					stall.position + Vector2(34, 0),
				]), Color(0.85, 0.22, 0.22))
		"alley":
			draw_rect(Rect2(at + Vector2(-18, -70), Vector2(36, 140)), Color(0.55, 0.5, 0.46))
			draw_rect(Rect2(at + Vector2(-8, -8), Vector2(16, 28)), Color(0.25, 0.18, 0.14))
			draw_circle(at + Vector2(0, -40), 5, Color(0.98, 0.86, 0.4))
		"embankment":
			draw_rect(Rect2(at + Vector2(-90, -16), Vector2(180, 28)), Color(0.78, 0.58, 0.36))
			draw_circle(at + Vector2(-40, 8), 6, Color(0.95, 0.95, 0.9))
			draw_circle(at + Vector2(40, 8), 6, Color(0.95, 0.95, 0.9))


func _on_road(point: Vector2) -> bool:
	for x in [-768.0, -256.0, 256.0, 768.0]:
		if absf(point.x - x) < 78.0:
			return true
	for y in [-768.0, -256.0, 256.0, 768.0]:
		if absf(point.y - y) < 78.0:
			return true
	return false


func _near_place(point: Vector2) -> bool:
	for id in MapLayout.ids():
		if point.distance_to(MapLayout.pos_of(id)) < 150.0:
			return true
	return false
