extends Node3D

## Житель квартала (капсула + Label3D).

var npc_id := ""
var case_id := ""
var display_name := ""
var look := "man"
var talk_radius := 110.0

var _marker: MeshInstance3D
var _label: Label3D


func setup(data: Dictionary) -> void:
	npc_id = str(data.get("id", ""))
	case_id = str(data.get("case_id", ""))
	display_name = str(data.get("name", "Житель"))
	look = str(data.get("look", "man"))
	var pos2: Vector2 = data.get("pos", Vector2.ZERO)
	global_position = MapLayout.to_3d(pos2, 0.0)
	_build_visual()


func can_talk() -> bool:
	return not case_id.is_empty() and not GameState.is_case_closed(case_id)


func contains_xz(world_pos: Vector3) -> bool:
	var a := Vector2(global_position.x, global_position.z)
	var b := Vector2(world_pos.x, world_pos.z)
	return a.distance_to(b) <= talk_radius


func _build_visual() -> void:
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 11.0
	capsule.height = 34.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _clothes_color()
	capsule.material = mat
	body.mesh = capsule
	body.position = Vector3(0, 17, 0)
	add_child(body)

	var head := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 8.0
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.86, 0.72, 0.58)
	sphere.material = skin
	head.mesh = sphere
	head.position = Vector3(0, 32, 0)
	add_child(head)

	_label = Label3D.new()
	_label.text = display_name
	_label.font_size = 48
	_label.modulate = Color(0.15, 0.1, 0.08)
	_label.outline_modulate = Color(1, 0.97, 0.9)
	_label.outline_size = 8
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.position = Vector3(0, 48, 0)
	add_child(_label)

	_marker = MeshInstance3D.new()
	var mark_mesh := SphereMesh.new()
	mark_mesh.radius = 6.0
	var mark_mat := StandardMaterial3D.new()
	mark_mat.albedo_color = Color(0.98, 0.82, 0.28)
	mark_mat.emission_enabled = true
	mark_mat.emission = Color(0.98, 0.82, 0.28)
	mark_mat.emission_energy_multiplier = 0.6
	mark_mesh.material = mark_mat
	_marker.mesh = mark_mesh
	_marker.position = Vector3(0, 52, 0)
	add_child(_marker)

	var area := Area3D.new()
	area.collision_layer = 2
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = true
	var shape := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = talk_radius
	shape.shape = sphere_shape
	area.add_child(shape)
	area.set_meta("kind", "npc")
	area.set_meta("npc", self)
	add_child(area)


func _clothes_color() -> Color:
	match look:
		"kids":
			return Color(0.35, 0.55, 0.4)
		"girl":
			return Color(0.55, 0.35, 0.42)
		"baker":
			return Color(0.85, 0.82, 0.75)
		_:
			return Color(0.3, 0.34, 0.42)


func _process(_delta: float) -> void:
	if _marker == null:
		return
	var closed := GameState.is_case_closed(case_id)
	if can_talk() and GameState.active_case_id != case_id:
		_marker.visible = true
		var bob := sin(Time.get_ticks_msec() * 0.008) * 3.0
		_marker.position.y = 52.0 + bob
		var mat := (_marker.mesh as SphereMesh).material as StandardMaterial3D
		if mat:
			mat.albedo_color = Color(0.98, 0.82, 0.28)
			mat.emission = Color(0.98, 0.82, 0.28)
	elif closed:
		_marker.visible = true
		_marker.position.y = 52.0
		var mat2 := (_marker.mesh as SphereMesh).material as StandardMaterial3D
		if mat2:
			mat2.albedo_color = Color(0.45, 0.8, 0.45)
			mat2.emission = Color(0.45, 0.8, 0.45)
	else:
		_marker.visible = false
