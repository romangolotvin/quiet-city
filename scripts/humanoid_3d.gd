class_name Humanoid3D

## Stylized-человечек из примитивов + idle/walk анимация конечностей.

const SKIN := Color(0.88, 0.72, 0.58)
const SKIN_DARK := Color(0.72, 0.52, 0.4)


static func build(parent: Node3D, look: String = "man", scale: float = 1.0) -> Node3D:
	var root := Node3D.new()
	root.name = "Humanoid"
	parent.add_child(root)

	var clothes := _clothes(look)
	var pants := _pants(look)
	var hair := _hair(look)
	var skin := SKIN if look != "stranger" else SKIN_DARK
	var s := scale
	if look == "kids":
		s *= 0.78

	var torso := Node3D.new()
	torso.name = "Torso"
	root.add_child(torso)
	if look == "girl":
		_box(torso, Vector3(0, 24.0 * s, 0), Vector3(18.0 * s, 16.0 * s, 10.0 * s), clothes)
		_box(torso, Vector3(0, 16.0 * s, 0), Vector3(22.0 * s, 10.0 * s, 12.0 * s), clothes)
	else:
		_box(torso, Vector3(0, 26.0 * s, 0), Vector3(18.0 * s, 20.0 * s, 10.0 * s), clothes)

	var leg_l := Node3D.new()
	leg_l.name = "LegL"
	leg_l.position = Vector3(-5.5 * s, 18.0 * s, 0)
	root.add_child(leg_l)
	_box(leg_l, Vector3(0, -9.0 * s, 0), Vector3(7.0 * s, 18.0 * s, 7.0 * s), pants)
	_box(leg_l, Vector3(0, -16.5 * s, 2.0 * s), Vector3(8.0 * s, 3.0 * s, 11.0 * s), Color(0.18, 0.14, 0.12))

	var leg_r := Node3D.new()
	leg_r.name = "LegR"
	leg_r.position = Vector3(5.5 * s, 18.0 * s, 0)
	root.add_child(leg_r)
	_box(leg_r, Vector3(0, -9.0 * s, 0), Vector3(7.0 * s, 18.0 * s, 7.0 * s), pants)
	_box(leg_r, Vector3(0, -16.5 * s, 2.0 * s), Vector3(8.0 * s, 3.0 * s, 11.0 * s), Color(0.18, 0.14, 0.12))

	var arm_l := Node3D.new()
	arm_l.name = "ArmL"
	arm_l.position = Vector3(-12.0 * s, 34.0 * s, 0)
	root.add_child(arm_l)
	_box(arm_l, Vector3(0, -8.0 * s, 0), Vector3(5.0 * s, 18.0 * s, 5.0 * s), clothes)
	_sphere(arm_l, Vector3(0, -18.0 * s, 0), 3.2 * s, skin)

	var arm_r := Node3D.new()
	arm_r.name = "ArmR"
	arm_r.position = Vector3(12.0 * s, 34.0 * s, 0)
	root.add_child(arm_r)
	_box(arm_r, Vector3(0, -8.0 * s, 0), Vector3(5.0 * s, 18.0 * s, 5.0 * s), clothes)
	_sphere(arm_r, Vector3(0, -18.0 * s, 0), 3.2 * s, skin)

	var head := Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 37.0 * s, 0)
	root.add_child(head)
	_box(head, Vector3(0, 0, 0), Vector3(5.0 * s, 4.0 * s, 5.0 * s), skin)
	_sphere(head, Vector3(0, 7.0 * s, 0), 9.0 * s, skin)
	_sphere(head, Vector3(-3.2 * s, 8.0 * s, 7.2 * s), 1.35 * s, Color(0.12, 0.1, 0.08))
	_sphere(head, Vector3(3.2 * s, 8.0 * s, 7.2 * s), 1.35 * s, Color(0.12, 0.1, 0.08))
	match look:
		"baker":
			_box(head, Vector3(0, 15.0 * s, 0), Vector3(16.0 * s, 6.0 * s, 16.0 * s), Color(0.96, 0.96, 0.94))
			_box(head, Vector3(0, 19.0 * s, 0), Vector3(10.0 * s, 8.0 * s, 10.0 * s), Color(0.98, 0.98, 0.96))
		"girl":
			_sphere(head, Vector3(0, 11.0 * s, -1.0 * s), 9.5 * s, hair)
			_sphere(head, Vector3(-8.0 * s, 5.0 * s, 0), 4.5 * s, hair)
			_sphere(head, Vector3(8.0 * s, 5.0 * s, 0), 4.5 * s, hair)
		"kids":
			_sphere(head, Vector3(0, 11.0 * s, -1.0 * s), 8.5 * s, hair)
		"man":
			_box(head, Vector3(0, 12.0 * s, -1.0 * s), Vector3(16.0 * s, 5.0 * s, 14.0 * s), hair)
		_:
			_sphere(head, Vector3(0, 11.5 * s, -1.0 * s), 9.2 * s, hair)

	root.set_meta("head_y", 54.0 * s)
	root.set_meta("scale_s", s)
	root.set_meta("anim_t", 0.0)
	return root


static func head_height(root: Node3D) -> float:
	if root and root.has_meta("head_y"):
		return float(root.get_meta("head_y"))
	return 48.0


## walking_amount 0..1, talk_bob — лёгкий кивок головы (диалог).
static func animate(root: Node3D, delta: float, walking_amount: float, talk_bob: bool = false) -> void:
	if root == null:
		return
	var t: float = float(root.get_meta("anim_t", 0.0))
	var walk := clampf(walking_amount, 0.0, 1.0)
	var speed := lerpf(1.4, 7.5, walk)
	t += delta * speed
	root.set_meta("anim_t", t)

	var leg_l := root.get_node_or_null("LegL") as Node3D
	var leg_r := root.get_node_or_null("LegR") as Node3D
	var arm_l := root.get_node_or_null("ArmL") as Node3D
	var arm_r := root.get_node_or_null("ArmR") as Node3D
	var torso := root.get_node_or_null("Torso") as Node3D
	var head := root.get_node_or_null("Head") as Node3D

	var swing := sin(t) * walk
	var idle := sin(t * 0.55) * (1.0 - walk)

	if leg_l:
		leg_l.rotation.x = swing * 0.55 + idle * 0.03
	if leg_r:
		leg_r.rotation.x = -swing * 0.55 + idle * 0.03
	if arm_l:
		arm_l.rotation.x = -swing * 0.45 + idle * 0.05
	if arm_r:
		arm_r.rotation.x = swing * 0.45 + idle * 0.05
	if torso:
		torso.position.y = absf(sin(t)) * walk * 1.4 + idle * 0.6
		torso.rotation.y = sin(t * 0.5) * walk * 0.04
	if head:
		var bob := sin(t * 0.7) * 0.035
		if talk_bob:
			bob += sin(t * 2.2) * 0.08
		head.rotation.x = bob + idle * 0.02
		head.position.y = float(root.get_meta("scale_s", 1.0)) * 37.0 + idle * 0.35


static func _clothes(look: String) -> Color:
	match look:
		"kids":
			return Color(0.32, 0.62, 0.42)
		"girl":
			return Color(0.72, 0.38, 0.48)
		"baker":
			return Color(0.92, 0.9, 0.84)
		"man":
			return Color(0.28, 0.36, 0.48)
		_:
			return Color(0.35, 0.38, 0.42)


static func _pants(look: String) -> Color:
	match look:
		"kids":
			return Color(0.28, 0.35, 0.55)
		"girl":
			return Color(0.72, 0.38, 0.48)
		"baker":
			return Color(0.35, 0.32, 0.3)
		_:
			return Color(0.22, 0.24, 0.3)


static func _hair(look: String) -> Color:
	match look:
		"girl":
			return Color(0.35, 0.18, 0.12)
		"kids":
			return Color(0.45, 0.28, 0.14)
		"baker":
			return Color(0.55, 0.4, 0.25)
		_:
			return Color(0.2, 0.14, 0.1)


static func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material = mat
	mi.mesh = mesh
	mi.position = pos
	parent.add_child(mi)


static func _sphere(parent: Node3D, pos: Vector3, radius: float, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material = mat
	mi.mesh = mesh
	mi.position = pos
	parent.add_child(mi)
