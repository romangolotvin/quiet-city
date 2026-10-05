extends Node3D

## Житель квартала: человечек + idle + пульсирующая точка дела.

var npc_id := ""
var case_id := ""
var display_name := ""
var look := "man"
var talk_radius := 110.0

var _marker: MeshInstance3D
var _label: Label3D
var _human: Node3D
var _head_y := 54.0
var _talk_bob := false
var _marker_base_y := 70.0


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


func head_world_y() -> float:
	return global_position.y + _head_y


func set_talk_bob(enabled: bool) -> void:
	_talk_bob = enabled


func _build_visual() -> void:
	_human = Humanoid3D.build(self, look, 1.0)
	_head_y = Humanoid3D.head_height(_human)
	_marker_base_y = _head_y + 16.0

	_label = Label3D.new()
	_label.text = display_name
	_label.font_size = 48
	_label.modulate = Color(0.15, 0.1, 0.08)
	_label.outline_modulate = Color(1, 0.97, 0.9)
	_label.outline_size = 8
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.position = Vector3(0, _head_y + 10.0, 0)
	add_child(_label)

	_marker = MeshInstance3D.new()
	var mark_mesh := SphereMesh.new()
	mark_mesh.radius = 5.5
	var mark_mat := StandardMaterial3D.new()
	mark_mat.albedo_color = Color(0.98, 0.82, 0.28)
	mark_mat.emission_enabled = true
	mark_mat.emission = Color(0.98, 0.82, 0.28)
	mark_mat.emission_energy_multiplier = 0.7
	mark_mesh.material = mark_mat
	_marker.mesh = mark_mesh
	_marker.position = Vector3(0, _marker_base_y, 0)
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


func _process(delta: float) -> void:
	if _human:
		Humanoid3D.animate(_human, delta, 0.0, _talk_bob)
	if _marker == null:
		return
	var closed := GameState.is_case_closed(case_id)
	var t := Time.get_ticks_msec() * 0.001
	if can_talk() and GameState.active_case_id != case_id:
		_marker.visible = true
		var bob := sin(t * 2.4) * 4.0
		var pulse := 1.0 + sin(t * 3.2) * 0.18
		_marker.position.y = _marker_base_y + bob
		_marker.scale = Vector3(pulse, pulse, pulse)
		var mat := (_marker.mesh as SphereMesh).material as StandardMaterial3D
		if mat:
			mat.albedo_color = Color(0.98, 0.82, 0.28)
			mat.emission = Color(0.98, 0.82, 0.28)
			mat.emission_energy_multiplier = 0.55 + sin(t * 3.2) * 0.35
	elif closed:
		_marker.visible = true
		_marker.position.y = _marker_base_y
		_marker.scale = Vector3.ONE
		var mat2 := (_marker.mesh as SphereMesh).material as StandardMaterial3D
		if mat2:
			mat2.albedo_color = Color(0.45, 0.8, 0.45)
			mat2.emission = Color(0.45, 0.8, 0.45)
			mat2.emission_energy_multiplier = 0.45
	else:
		_marker.visible = false
