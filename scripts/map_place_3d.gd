extends Node3D

## Маркер места на карте (кольцо + Label3D).

var place_id := ""
var place_name := ""
var idle_text := ""
var hit_radius := 90.0


func setup(id: String) -> void:
	var data := MapLayout.place(id)
	place_id = id
	place_name = str(data["name"])
	idle_text = str(data["idle"])
	global_position = MapLayout.to_3d(data["pos"], 0.0)
	_build()


func contains_xz(world_pos: Vector3) -> bool:
	var a := Vector2(global_position.x, global_position.z)
	var b := Vector2(world_pos.x, world_pos.z)
	return a.distance_to(b) <= hit_radius


func _build() -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 28.0
	torus.outer_radius = 34.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.1, 0.08, 0.85)
	torus.material = mat
	ring.mesh = torus
	ring.position = Vector3(0, 2, 0)
	ring.rotation_degrees = Vector3(90, 0, 0)
	add_child(ring)

	var pin := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 5.0
	var pin_mat := StandardMaterial3D.new()
	pin_mat.albedo_color = Color(0.15, 0.1, 0.08)
	sphere.material = pin_mat
	pin.mesh = sphere
	pin.position = Vector3(0, 8, 0)
	add_child(pin)

	var label := Label3D.new()
	label.text = place_name
	label.font_size = 42
	label.modulate = Color(0.15, 0.1, 0.08)
	label.outline_modulate = Color(1, 0.97, 0.9)
	label.outline_size = 6
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 40, 0)
	add_child(label)

	var area := Area3D.new()
	area.collision_layer = 4
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = true
	var shape := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = hit_radius
	shape.shape = sphere_shape
	area.add_child(shape)
	area.set_meta("kind", "place")
	area.set_meta("place", self)
	add_child(area)
