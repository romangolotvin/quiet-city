extends Node3D

## Low-poly город из примитивов по MapLayout.

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
	_build()


func _build() -> void:
	_add_box(Vector3(0, -4, 0), Vector3(4200, 8, 3600), GROUND, true)
	_draw_roads()
	_draw_water()
	_draw_blocks()
	for id in MapLayout.ids():
		var data := MapLayout.place(id)
		_draw_art(str(data["art"]), MapLayout.to_3d(data["pos"], 0.0))


func _draw_roads() -> void:
	for x in [-768.0, -256.0, 256.0, 768.0]:
		_add_box(Vector3(x, 0.5, 0), Vector3(92, 1, 3000), ROAD, false)
		_add_box(Vector3(x, 1.0, 0), Vector3(4, 0.4, 3000), LANE, false)
	for z in [-768.0, -256.0, 256.0, 768.0]:
		_add_box(Vector3(0, 0.5, z), Vector3(3800, 1, 92), ROAD, false)
		_add_box(Vector3(0, 1.0, z), Vector3(3800, 0.4, 4), LANE, false)


func _draw_water() -> void:
	_add_box(Vector3(0, -2, 1090), Vector3(3800, 6, 220), WATER, true)
	_add_box(Vector3(0, 2, 980), Vector3(140, 8, 160), Color(0.72, 0.5, 0.28), true)


func _draw_blocks() -> void:
	var n := 0
	for gx in range(-6, 7):
		for gz in range(-5, 6):
			var center := Vector3(gx * 256.0, 0, gz * 256.0)
			if _on_road(center) or _near_place(center):
				continue
			var roof: Color = ROOFS[posmod(n, ROOFS.size())]
			n += 1
			var h := 70.0 + float(posmod(n, 3)) * 18.0
			_add_box(center + Vector3(0, h * 0.5, 0), Vector3(140, h, 110), roof, true)
			_add_box(center + Vector3(-18, h * 0.55, 40), Vector3(14, 14, 4), Color(0.86, 0.95, 1.0), false)
			_add_box(center + Vector3(18, h * 0.55, 40), Vector3(14, 14, 4), Color(0.86, 0.95, 1.0), false)
			_add_box(center + Vector3(0, 2, 58), Vector3(130, 4, 12), BLOCK, false)


func _draw_art(kind: String, at: Vector3) -> void:
	match kind:
		"plaza":
			_add_cylinder(at + Vector3(0, 2, 0), 78, 4, Color(0.98, 0.82, 0.42), false)
			_add_cylinder(at + Vector3(0, 8, 0), 24, 16, Color(0.42, 0.78, 0.98), true)
		"bakery":
			_add_box(at + Vector3(0, 30, 0), Vector3(116, 60, 80), Color(0.98, 0.55, 0.32), true)
			_add_box(at + Vector3(0, 62, 0), Vector3(124, 12, 88), Color(0.95, 0.3, 0.28), true)
			_add_box(at + Vector3(0, 20, 42), Vector3(28, 28, 6), Color(0.55, 0.82, 0.95), false)
		"yard":
			_add_box(at + Vector3(0, 1, 0), Vector3(128, 2, 96), Color(0.5, 0.84, 0.4), false)
			_add_box(at + Vector3(-20, 16, 0), Vector3(4, 32, 4), Color(0.35, 0.24, 0.12), true)
			_add_box(at + Vector3(20, 16, 0), Vector3(4, 32, 4), Color(0.35, 0.24, 0.12), true)
		"gate":
			_add_box(at + Vector3(0, 8, 0), Vector3(96, 12, 10), Color(0.55, 0.34, 0.16), true)
			_add_box(at + Vector3(-52, 22, 0), Vector3(12, 44, 12), Color(0.32, 0.2, 0.1), true)
			_add_box(at + Vector3(52, 22, 0), Vector3(12, 44, 12), Color(0.32, 0.2, 0.1), true)
		"porch":
			_add_box(at + Vector3(0, 24, 0), Vector3(100, 48, 70), Color(0.98, 0.64, 0.46), true)
			_add_box(at + Vector3(0, 14, 38), Vector3(28, 28, 6), Color(0.4, 0.24, 0.14), false)
			_add_box(at + Vector3(0, 3, 42), Vector3(80, 6, 16), Color(0.75, 0.58, 0.4), true)
		"house":
			_add_box(at + Vector3(0, 28, 0), Vector3(92, 56, 70), Color(0.4, 0.58, 0.94), true)
			_add_box(at + Vector3(0, 62, 0), Vector3(100, 16, 78), Color(0.22, 0.36, 0.72), true)
		"park":
			_add_box(at + Vector3(0, 1, 0), Vector3(160, 2, 140), Color(0.46, 0.82, 0.42), false)
			for offset in [Vector3(-30, 0, -10), Vector3(20, 0, 16), Vector3(-10, 0, 28), Vector3(36, 0, -24)]:
				_add_cylinder(at + offset + Vector3(0, 18, 0), 10, 20, Color(0.35, 0.22, 0.1), true)
				_add_cylinder(at + offset + Vector3(0, 36, 0), 18, 22, Color(0.2, 0.58, 0.26), false)
		"market":
			for i in 3:
				var ox := -36.0 + float(i) * 36.0
				var col := Color(0.95, 0.45, 0.35) if i != 1 else Color(0.95, 0.78, 0.28)
				_add_box(at + Vector3(ox, 16, 0), Vector3(28, 32, 36), col, true)
				_add_box(at + Vector3(ox, 36, 0), Vector3(34, 8, 42), Color(0.85, 0.22, 0.22), true)
		"alley":
			_add_box(at + Vector3(0, 30, 0), Vector3(36, 60, 140), Color(0.55, 0.5, 0.46), true)
			_add_box(at + Vector3(0, 14, 0), Vector3(14, 28, 8), Color(0.25, 0.18, 0.14), false)
		"embankment":
			_add_box(at + Vector3(0, 6, 0), Vector3(180, 12, 36), Color(0.78, 0.58, 0.36), true)
		"base":
			# Три стены + крыша: вход спереди открыт, к компьютеру можно подойти.
			_add_box(at + Vector3(0, 40, -55), Vector3(150, 80, 10), Color(0.55, 0.72, 0.55), true)
			_add_box(at + Vector3(-70, 40, 0), Vector3(10, 80, 120), Color(0.55, 0.72, 0.55), true)
			_add_box(at + Vector3(70, 40, 0), Vector3(10, 80, 120), Color(0.55, 0.72, 0.55), true)
			_add_box(at + Vector3(0, 84, 0), Vector3(160, 14, 130), Color(0.28, 0.48, 0.34), true)
			_add_box(at + Vector3(0, 2, 0), Vector3(140, 4, 110), Color(0.72, 0.62, 0.48), false)
			# Компьютерный стол у входа
			_add_box(at + Vector3(0, 12, 35), Vector3(44, 24, 30), Color(0.45, 0.35, 0.25), true)
			_add_box(at + Vector3(0, 28, 35), Vector3(30, 18, 8), Color(0.2, 0.55, 0.85), false)
			_add_box(at + Vector3(0, 28, 38), Vector3(24, 14, 2), Color(0.35, 0.85, 0.95), false)


func _on_road(point: Vector3) -> bool:
	for x in [-768.0, -256.0, 256.0, 768.0]:
		if absf(point.x - x) < 78.0:
			return true
	for z in [-768.0, -256.0, 256.0, 768.0]:
		if absf(point.z - z) < 78.0:
			return true
	return false


func _near_place(point: Vector3) -> bool:
	for id in MapLayout.ids():
		if point.distance_to(MapLayout.to_3d(MapLayout.pos_of(id))) < 150.0:
			return true
	return false


func _add_box(pos: Vector3, size: Vector3, color: Color, collide: bool) -> void:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material = mat
	mi.mesh = mesh
	mi.position = pos
	add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		col.shape = shape
		body.add_child(col)
		add_child(body)


func _add_cylinder(pos: Vector3, radius: float, height: float, color: Color, collide: bool) -> void:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material = mat
	mi.mesh = mesh
	mi.position = pos
	add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		var col := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
		col.shape = shape
		body.add_child(col)
		add_child(body)
