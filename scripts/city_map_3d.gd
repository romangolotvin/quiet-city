extends Node3D

## Жилой квартал: детальный low-poly город по MapLayout + лёгкий ambient.

const GROUND := Color(0.55, 0.72, 0.42)
const SAND := Color(0.94, 0.86, 0.62)
const ROAD := Color(0.42, 0.42, 0.46)
const SIDEWALK := Color(0.82, 0.8, 0.76)
const LANE := Color(0.95, 0.86, 0.35)
const DIRT := Color(0.62, 0.5, 0.34)
const WATER := Color(0.28, 0.62, 0.86)
const WALL_A := Color(0.93, 0.86, 0.72)
const WALL_B := Color(0.86, 0.78, 0.68)
const WALL_C := Color(0.78, 0.82, 0.86)

## Оси проезжих (X и Z). Половина дороги ~55 + тротуар ~70 + половина дома ~70+.
const ROAD_AXES: Array[float] = [-768.0, -256.0, 256.0, 768.0]
const CLEAR_ZONE := 195.0

const ROOFS := [
	Color(0.78, 0.28, 0.24),
	Color(0.86, 0.48, 0.18),
	Color(0.28, 0.42, 0.72),
	Color(0.55, 0.32, 0.28),
	Color(0.32, 0.55, 0.42),
	Color(0.7, 0.55, 0.28),
]

var _anim_nodes: Array[Dictionary] = []
var _ambient_t := 0.0


func _ready() -> void:
	_build()


func _process(delta: float) -> void:
	_ambient_t += delta
	for item in _anim_nodes:
		var node: Node3D = item["node"]
		var kind: String = item["kind"]
		var base_y: float = item["base_y"]
		var phase: float = item["phase"]
		if kind == "fountain":
			var bob := sin(_ambient_t * 2.8 + phase) * 3.5
			var pulse := 1.0 + sin(_ambient_t * 3.4 + phase) * 0.12
			node.position.y = base_y + bob
			node.scale = Vector3(pulse, 1.0 + bob * 0.04, pulse)
		elif kind == "tree":
			node.rotation.z = sin(_ambient_t * 0.7 + phase) * 0.04
			node.rotation.x = cos(_ambient_t * 0.55 + phase) * 0.025
		elif kind == "lamp":
			var glow := 0.85 + sin(_ambient_t * 1.6 + phase) * 0.15
			var mi := node as MeshInstance3D
			if mi and mi.mesh and mi.mesh.material:
				var mat := mi.mesh.material as StandardMaterial3D
				if mat:
					mat.emission_energy_multiplier = glow


func _build() -> void:
	_add_box(Vector3(0, -6, 0), Vector3(4600, 12, 4000), GROUND, true)
	_draw_parks_patches()
	_draw_roads()
	_draw_sidewalks()
	_draw_water()
	_draw_blocks()
	_draw_street_props()
	for id in MapLayout.ids():
		var data := MapLayout.place(id)
		_draw_art(str(data["art"]), MapLayout.to_3d(data["pos"], 0.0))


func _draw_parks_patches() -> void:
	for i in 28:
		var gx := float((i % 7) - 3) * 320.0 + float(posmod(i * 17, 40))
		var gz := float((i / 7) - 2) * 340.0 + float(posmod(i * 29, 50))
		var c := Vector3(gx, 0.2, gz)
		if _on_road(c) or _near_place(c):
			continue
		var col := Color(0.48, 0.68, 0.36) if posmod(i, 2) == 0 else SAND
		_add_box(c + Vector3(0, 0.3, 0), Vector3(90 + posmod(i, 5) * 12.0, 0.6, 70 + posmod(i, 4) * 10.0), col, false)


func _draw_roads() -> void:
	for x in ROAD_AXES:
		_add_box(Vector3(x, 0.4, 0), Vector3(110, 0.8, 3200), ROAD, false)
		_add_box(Vector3(x, 0.85, 0), Vector3(4, 0.2, 3200), LANE, false)
		_add_box(Vector3(x - 52, 1.2, 0), Vector3(6, 1.6, 3200), SIDEWALK, true)
		_add_box(Vector3(x + 52, 1.2, 0), Vector3(6, 1.6, 3200), SIDEWALK, true)
	for z in ROAD_AXES:
		_add_box(Vector3(0, 0.4, z), Vector3(4000, 0.8, 110), ROAD, false)
		_add_box(Vector3(0, 0.85, z), Vector3(4000, 0.2, 4), LANE, false)
		_add_box(Vector3(0, 1.2, z - 52), Vector3(4000, 1.6, 6), SIDEWALK, true)
		_add_box(Vector3(0, 1.2, z + 52), Vector3(4000, 1.6, 6), SIDEWALK, true)
	for i in 5:
		var o := -40.0 + float(i) * 20.0
		_add_box(Vector3(o, 0.9, 55), Vector3(12, 0.2, 28), Color(0.95, 0.95, 0.92), false)
		_add_box(Vector3(55, 0.9, o), Vector3(28, 0.2, 12), Color(0.95, 0.95, 0.92), false)


func _draw_sidewalks() -> void:
	for x in ROAD_AXES:
		_add_box(Vector3(x - 70, 0.6, 0), Vector3(28, 0.5, 3000), SIDEWALK, false)
		_add_box(Vector3(x + 70, 0.6, 0), Vector3(28, 0.5, 3000), SIDEWALK, false)
	for z in ROAD_AXES:
		_add_box(Vector3(0, 0.6, z - 70), Vector3(3600, 0.5, 28), SIDEWALK, false)
		_add_box(Vector3(0, 0.6, z + 70), Vector3(3600, 0.5, 28), SIDEWALK, false)


func _draw_water() -> void:
	_add_box(Vector3(0, -3, 1120), Vector3(4000, 8, 280), WATER, true)
	_add_box(Vector3(0, 6, 1000), Vector3(160, 10, 180), Color(0.62, 0.48, 0.32), true)
	_add_box(Vector3(-70, 18, 1000), Vector3(8, 22, 160), Color(0.55, 0.42, 0.28), true)
	_add_box(Vector3(70, 18, 1000), Vector3(8, 22, 160), Color(0.55, 0.42, 0.28), true)
	for i in 12:
		var x := -900.0 + float(i) * 160.0
		_add_box(Vector3(x, 10, 960), Vector3(6, 18, 6), Color(0.7, 0.7, 0.72), true)
	_add_box(Vector3(0, 16, 960), Vector3(1900, 3, 4), Color(0.75, 0.75, 0.78), false)


func _draw_blocks() -> void:
	var n := 0
	for gx in range(-7, 8):
		for gz in range(-6, 7):
			var center := Vector3(gx * 256.0, 0, gz * 256.0)
			# Не ставим procedural-блоки на оси дорог / перекрёстки.
			if _on_road(center) or _near_place(center):
				continue
			n += 1
			var wall: Color = [WALL_A, WALL_B, WALL_C][posmod(n, 3)]
			var roof: Color = ROOFS[posmod(n, ROOFS.size())]
			var floors := 1 + posmod(n, 3)
			var h := 48.0 + float(floors) * 28.0
			var w := 100.0 + float(posmod(n * 3, 4)) * 8.0
			var d := 80.0 + float(posmod(n * 5, 3)) * 6.0
			# Сжимаем, чтобы footprint не лез на асфальт+тротуар.
			var max_w := _max_span_on_axis(center.x) - 8.0
			var max_d := _max_span_on_axis(center.z) - 8.0
			w = minf(w, max_w)
			d = minf(d, max_d)
			if w < 40.0 or d < 40.0:
				continue
			center = _inset_from_roads(center, w * 0.5, d * 0.5)
			if _on_road(center):
				continue
			_add_building(center, Vector3(w, h, d), wall, roof, floors)
			if posmod(n, 2) == 0:
				_add_box(center + Vector3(0, 1.5, d * 0.55 + 8), Vector3(w * 0.85, 3, 12), Color(0.32, 0.58, 0.28), false)


func _add_building(center: Vector3, size: Vector3, wall: Color, roof: Color, floors: int) -> void:
	_add_box(center + Vector3(0, size.y * 0.5, 0), size, wall, true)
	_add_box(center + Vector3(0, size.y + 6, 0), Vector3(size.x + 10, 12, size.z + 10), roof, true)
	_add_box(center + Vector3(0, 12, size.z * 0.5 + 1), Vector3(14, 24, 3), Color(0.35, 0.22, 0.14), false)
	for f in floors:
		var y := 28.0 + float(f) * 26.0
		for sx in [-1.0, 1.0]:
			_add_box(center + Vector3(sx * size.x * 0.22, y, size.z * 0.5 + 1.2), Vector3(12, 14, 2.5), Color(0.55, 0.78, 0.95), false)
			_add_box(center + Vector3(sx * size.x * 0.22, y, -size.z * 0.5 - 1.2), Vector3(12, 14, 2.5), Color(0.45, 0.7, 0.9), false)


func _draw_street_props() -> void:
	for x in ROAD_AXES:
		for z in range(-4, 5):
			var zz := float(z) * 256.0
			if absf(zz) < 40.0 and absf(x) < 40.0:
				continue
			_add_lamp(Vector3(x - 78, 0, zz + 40))
			_add_lamp(Vector3(x + 78, 0, zz - 40))
	_add_bench(Vector3(90, 0, -70))
	_add_bench(Vector3(-100, 0, 80))
	_add_bench(Vector3(70, 0, 110))


func _add_lamp(at: Vector3) -> void:
	_add_cylinder(at + Vector3(0, 22, 0), 2.2, 44, Color(0.35, 0.35, 0.38), true)
	var head := _add_box_node(at + Vector3(0, 46, 0), Vector3(10, 4, 10), Color(0.95, 0.9, 0.7), false)
	var mat := (head.mesh as BoxMesh).material as StandardMaterial3D
	if mat:
		mat.emission_enabled = true
		mat.emission = Color(0.95, 0.88, 0.55)
		mat.emission_energy_multiplier = 0.9
	_anim_nodes.append({"node": head, "kind": "lamp", "base_y": 46.0, "phase": at.x * 0.01 + at.z * 0.007})


func _add_bench(at: Vector3) -> void:
	_add_box(at + Vector3(0, 8, 0), Vector3(36, 3, 12), Color(0.55, 0.35, 0.2), true)
	_add_box(at + Vector3(0, 14, -5), Vector3(36, 10, 3), Color(0.55, 0.35, 0.2), false)
	_add_box(at + Vector3(-14, 4, 0), Vector3(3, 8, 10), Color(0.3, 0.3, 0.32), true)
	_add_box(at + Vector3(14, 4, 0), Vector3(3, 8, 10), Color(0.3, 0.3, 0.32), true)


func _draw_art(kind: String, at: Vector3) -> void:
	# Landmark-арт, сидящий на оси дороги, сдвигаем во двор квартала.
	var half := _landmark_half(kind)
	at = _courtyard_from_roads(at, half.x, half.y)
	match kind:
		"plaza":
			_add_cylinder(at + Vector3(0, 1.5, 0), 95, 3, Color(0.9, 0.84, 0.7), false)
			_add_cylinder(at + Vector3(0, 4, 0), 70, 4, Color(0.86, 0.8, 0.66), false)
			_add_cylinder(at + Vector3(0, 14, 0), 18, 20, Color(0.72, 0.78, 0.86), true)
			_add_cylinder(at + Vector3(0, 28, 0), 28, 8, Color(0.4, 0.72, 0.95), false)
			var jet := _add_cylinder_node(at + Vector3(0, 36, 0), 10, 10, WATER, false)
			_anim_nodes.append({"node": jet, "kind": "fountain", "base_y": at.y + 36.0, "phase": 0.2})
			var spray := _add_cylinder_node(at + Vector3(0, 44, 0), 6, 8, Color(0.55, 0.82, 0.98, 0.85), false)
			_anim_nodes.append({"node": spray, "kind": "fountain", "base_y": at.y + 44.0, "phase": 1.1})
			for a in 6:
				var ang := float(a) * TAU / 6.0
				_add_box(at + Vector3(cos(ang) * 55, 6, sin(ang) * 55), Vector3(8, 10, 8), Color(0.75, 0.55, 0.35), true)
		"bakery":
			_add_building(at, Vector3(110, 70, 80), Color(0.96, 0.78, 0.58), Color(0.86, 0.28, 0.24), 2)
			_add_box(at + Vector3(0, 18, 42), Vector3(46, 28, 6), Color(0.55, 0.82, 0.95), false)
			_add_box(at + Vector3(0, 38, 46), Vector3(64, 6, 36), Color(0.92, 0.35, 0.28), true)
			_add_box(at + Vector3(-36, 8, 48), Vector3(16, 16, 16), Color(0.95, 0.7, 0.35), true)
			_add_box(at + Vector3(36, 8, 48), Vector3(16, 16, 16), Color(0.95, 0.7, 0.35), true)
		"yard":
			_add_box(at + Vector3(0, 1, 0), Vector3(130, 2, 100), Color(0.42, 0.72, 0.36), false)
			_add_box(at + Vector3(-28, 14, 0), Vector3(4, 28, 4), Color(0.4, 0.28, 0.16), true)
			_add_box(at + Vector3(28, 14, 0), Vector3(4, 28, 4), Color(0.4, 0.28, 0.16), true)
			_add_box(at + Vector3(0, 28, 0), Vector3(64, 3, 4), Color(0.55, 0.35, 0.2), false)
			_add_box(at + Vector3(0, 4, 30), Vector3(40, 6, 24), Color(0.7, 0.45, 0.25), true)
			_add_box(at + Vector3(45, 1, -26), Vector3(20, 2, 20), Color(0.95, 0.55, 0.2), false)
		"gate":
			_add_box(at + Vector3(0, 2, 0), Vector3(120, 4, 36), DIRT, false)
			_add_box(at + Vector3(-48, 28, 0), Vector3(14, 56, 14), Color(0.35, 0.22, 0.12), true)
			_add_box(at + Vector3(48, 28, 0), Vector3(14, 56, 14), Color(0.35, 0.22, 0.12), true)
			_add_box(at + Vector3(0, 52, 0), Vector3(110, 10, 12), Color(0.45, 0.28, 0.14), true)
			_add_box(at + Vector3(-18, 22, 6), Vector3(28, 40, 4), Color(0.5, 0.32, 0.16), false)
			_add_box(at + Vector3(18, 22, 6), Vector3(28, 40, 4), Color(0.5, 0.32, 0.16), false)
			_add_box(at + Vector3(42, 18, 8), Vector3(4, 20, 4), Color(0.3, 0.3, 0.32), true)
		"porch":
			_add_building(at + Vector3(0, 0, -10), Vector3(100, 64, 72), Color(0.95, 0.72, 0.55), Color(0.75, 0.35, 0.28), 2)
			_add_box(at + Vector3(0, 4, 38), Vector3(64, 8, 32), Color(0.72, 0.55, 0.38), true)
			_add_box(at + Vector3(0, 10, 50), Vector3(46, 4, 14), Color(0.68, 0.5, 0.34), true)
			_add_box(at + Vector3(-22, 18, 44), Vector3(4, 20, 4), Color(0.85, 0.85, 0.82), true)
			_add_box(at + Vector3(22, 18, 44), Vector3(4, 20, 4), Color(0.85, 0.85, 0.82), true)
			_add_box(at + Vector3(0, 30, 44), Vector3(46, 4, 4), Color(0.85, 0.85, 0.82), false)
		"house":
			_add_building(at, Vector3(100, 78, 76), Color(0.55, 0.68, 0.9), Color(0.22, 0.34, 0.62), 2)
			_add_box(at + Vector3(-28, 34, 40), Vector3(18, 22, 3), Color(0.2, 0.35, 0.7), false)
			_add_box(at + Vector3(28, 34, 40), Vector3(18, 22, 3), Color(0.2, 0.35, 0.7), false)
			_add_box(at + Vector3(0, 2, 48), Vector3(40, 4, 20), Color(0.7, 0.7, 0.72), true)
		"park":
			_add_box(at + Vector3(0, 1, 0), Vector3(180, 2, 150), Color(0.38, 0.7, 0.36), false)
			_add_box(at + Vector3(0, 1.4, 0), Vector3(36, 0.5, 120), Color(0.72, 0.62, 0.42), false)
			_add_box(at + Vector3(0, 1.4, 0), Vector3(130, 0.5, 24), Color(0.72, 0.62, 0.42), false)
			for offset in [
				Vector3(-50, 0, -30), Vector3(40, 0, 20), Vector3(-20, 0, 45),
				Vector3(55, 0, -40), Vector3(-60, 0, 10), Vector3(10, 0, -55)
			]:
				_add_tree(at + offset)
			_add_bench(at + Vector3(30, 0, -20))
			_add_bench(at + Vector3(-35, 0, 25))
		"market":
			_add_box(at + Vector3(0, 1, 0), Vector3(150, 2, 100), Color(0.78, 0.7, 0.55), false)
			for i in 4:
				var ox := -48.0 + float(i) * 32.0
				var col := Color(0.92, 0.42, 0.32) if posmod(i, 2) == 0 else Color(0.95, 0.78, 0.28)
				_add_box(at + Vector3(ox, 14, 0), Vector3(28, 28, 36), col, true)
				_add_box(at + Vector3(ox, 32, 0), Vector3(32, 8, 42), Color(0.75, 0.2, 0.18), true)
				_add_box(at + Vector3(ox, 8, 22), Vector3(24, 8, 12), Color(0.85, 0.65, 0.35), false)
		"alley":
			_add_box(at + Vector3(-28, 40, 0), Vector3(36, 80, 140), Color(0.58, 0.54, 0.5), true)
			_add_box(at + Vector3(28, 40, 0), Vector3(36, 80, 140), Color(0.52, 0.48, 0.46), true)
			_add_box(at + Vector3(0, 1, 0), Vector3(24, 2, 140), Color(0.35, 0.32, 0.3), false)
			_add_box(at + Vector3(0, 18, -36), Vector3(16, 32, 6), Color(0.22, 0.16, 0.12), false)
			_add_box(at + Vector3(-16, 6, 18), Vector3(14, 12, 14), Color(0.4, 0.35, 0.3), true)
			_add_box(at + Vector3(14, 8, 44), Vector3(12, 16, 12), Color(0.45, 0.4, 0.35), true)
		"embankment":
			_add_box(at + Vector3(0, 5, 0), Vector3(200, 10, 44), Color(0.72, 0.58, 0.4), true)
			_add_box(at + Vector3(0, 12, -16), Vector3(200, 3, 8), Color(0.78, 0.78, 0.8), false)
			for i in 8:
				_add_box(at + Vector3(-130.0 + float(i) * 36.0, 10, -16), Vector3(5, 14, 5), Color(0.7, 0.7, 0.74), true)
		"base":
			_add_box(at + Vector3(0, 2, 0), Vector3(140, 4, 110), Color(0.7, 0.62, 0.5), false)
			_add_box(at + Vector3(0, 42, -52), Vector3(150, 84, 12), Color(0.48, 0.68, 0.52), true)
			_add_box(at + Vector3(-70, 42, 0), Vector3(12, 84, 110), Color(0.48, 0.68, 0.52), true)
			_add_box(at + Vector3(70, 42, 0), Vector3(12, 84, 110), Color(0.48, 0.68, 0.52), true)
			_add_box(at + Vector3(0, 88, 0), Vector3(160, 14, 125), Color(0.28, 0.48, 0.36), true)
			_add_box(at + Vector3(-71, 40, -18), Vector3(3, 22, 18), Color(0.55, 0.82, 0.95), false)
			_add_box(at + Vector3(71, 40, -18), Vector3(3, 22, 18), Color(0.55, 0.82, 0.95), false)
			_add_box(at + Vector3(0, 14, 24), Vector3(46, 28, 30), Color(0.42, 0.32, 0.22), true)
			_add_box(at + Vector3(0, 32, 24), Vector3(30, 20, 8), Color(0.18, 0.2, 0.24), false)
			_add_box(at + Vector3(0, 32, 28), Vector3(24, 16, 2), Color(0.35, 0.85, 0.95), false)
			_add_box(at + Vector3(16, 30, 16), Vector3(8, 4, 12), Color(0.85, 0.85, 0.88), false)
			_add_box(at + Vector3(-18, 16, 48), Vector3(20, 32, 20), Color(0.45, 0.55, 0.7), true)


func _add_tree(at: Vector3) -> void:
	_add_cylinder(at + Vector3(0, 16, 0), 5, 32, Color(0.4, 0.26, 0.14), true)
	var crown := Node3D.new()
	crown.position = at
	add_child(crown)
	_add_cylinder_to(crown, Vector3(0, 38, 0), 20, 26, Color(0.22, 0.55, 0.28))
	_add_cylinder_to(crown, Vector3(0, 52, 0), 14, 18, Color(0.28, 0.62, 0.32))
	_anim_nodes.append({"node": crown, "kind": "tree", "base_y": 0.0, "phase": at.x * 0.02 + at.z * 0.015})


func _add_cylinder_to(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color) -> void:
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
	parent.add_child(mi)


func _add_box_node(pos: Vector3, size: Vector3, color: Color, collide: bool) -> MeshInstance3D:
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
	return mi


func _add_cylinder_node(pos: Vector3, radius: float, height: float, color: Color, collide: bool) -> MeshInstance3D:
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
	return mi


func _on_road(point: Vector3) -> bool:
	# Проезжая + тротуар + перекрёстки + запас под половину здания.
	for x in ROAD_AXES:
		if absf(point.x - x) < CLEAR_ZONE:
			return true
	for z in ROAD_AXES:
		if absf(point.z - z) < CLEAR_ZONE:
			return true
	return false


func _max_span_on_axis(coord: float) -> float:
	# Макс. ширина здания вдоль оси, чтобы края не заходили в CLEAR_ZONE.
	var lo := -99999.0
	var hi := 99999.0
	for road in ROAD_AXES:
		if road < coord:
			lo = maxf(lo, road + CLEAR_ZONE)
		elif road > coord:
			hi = minf(hi, road - CLEAR_ZONE)
		else:
			return 0.0
	return maxf(0.0, hi - lo)


func _inset_from_roads(center: Vector3, half_x: float, half_z: float) -> Vector3:
	var p := center
	for road in ROAD_AXES:
		if p.x >= road:
6			var need: float = road + CLEAR_ZONE + half_x
			if p.x < need:
				p.x = need
		else:
			var need2: float = road - CLEAR_ZONE - half_x
			if p.x > need2:
				p.x = need2
	for road in ROAD_AXES:
		if p.z >= road:
			var needz: float = road + CLEAR_ZONE + half_z
			if p.z < needz:
				p.z = needz
		else:
			var needz2: float = road - CLEAR_ZONE - half_z
			if p.z > needz2:
				p.z = needz2
	return p


func _courtyard_sign(coord: float, road: float) -> float:
	# Внутрь ближайшего квартала (к mid-point между соседними осями).
	var best_mid := road + 256.0
	var best_d := absf(best_mid - coord)
	for other in ROAD_AXES:
		if is_equal_approx(other, road):
			continue
		var mid := (road + other) * 0.5
		var d := absf(mid - coord)
		# Предпочитаем mid ближе к текущей клетке / к центру города.
		d += absf(mid) * 0.001
		if d < best_d:
			best_d = d
			best_mid = mid
	return 1.0 if best_mid >= road else -1.0


func _courtyard_from_roads(at: Vector3, half_x: float, half_z: float) -> Vector3:
	# Только если центр сидит на полосе дороги — сдвиг во двор на CLEAR + half.
	var p := at
	for road in ROAD_AXES:
		var dx := p.x - road
		if absf(dx) < CLEAR_ZONE:
			var s := signf(dx) if absf(dx) > 0.5 else _courtyard_sign(at.x, road)
			p.x = road + s * (CLEAR_ZONE + half_x)
	for road in ROAD_AXES:
		var dz := p.z - road
		if absf(dz) < CLEAR_ZONE:
			var s2 := signf(dz) if absf(dz) > 0.5 else _courtyard_sign(at.z, road)
			p.z = road + s2 * (CLEAR_ZONE + half_z)
	return p


func _landmark_half(kind: String) -> Vector2:
	match kind:
		"plaza":
			return Vector2(70, 70)
		"bakery":
			return Vector2(55, 45)
		"yard":
			return Vector2(65, 50)
		"gate":
			return Vector2(60, 20)
		"porch":
			return Vector2(55, 45)
		"house":
			return Vector2(55, 45)
		"park":
			return Vector2(90, 75)
		"market":
			return Vector2(75, 55)
		"alley":
			return Vector2(40, 70)
		"embankment":
			return Vector2(100, 25)
		"base":
			return Vector2(80, 65)
		_:
			return Vector2(60, 50)


func _near_place(point: Vector3) -> bool:
	for id in MapLayout.ids():
		var place_pos := MapLayout.to_3d(MapLayout.pos_of(id))
		var half := _landmark_half(str(MapLayout.place(id).get("art", "")))
		var nudged := _courtyard_from_roads(place_pos, half.x, half.y)
		if point.distance_to(nudged) < 200.0:
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
