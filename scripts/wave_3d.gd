extends Node3D

## Расширяющееся кольцо волны в 3D.

var color: Color = Color.WHITE
var max_radius: float = 160.0
var lifetime: float = 1.0

var _elapsed: float = 0.0
var _mesh: MeshInstance3D
var _torus: TorusMesh
var _mat: StandardMaterial3D


func _ready() -> void:
	_mesh = MeshInstance3D.new()
	_torus = TorusMesh.new()
	_torus.inner_radius = 6.0
	_torus.outer_radius = 10.0
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = color
	_mat.emission_enabled = true
	_mat.emission = color
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_torus.material = _mat
	_mesh.mesh = _torus
	_mesh.rotation_degrees = Vector3(90, 0, 0)
	add_child(_mesh)


func _process(delta: float) -> void:
	_elapsed += delta
	var t := clampf(_elapsed / lifetime, 0.0, 1.0)
	var r := lerpf(8.0, max_radius, t)
	_torus.inner_radius = maxf(r - 4.0, 1.0)
	_torus.outer_radius = r
	_mat.albedo_color.a = 1.0 - t
	_mat.emission_energy_multiplier = 1.0 - t
	if t >= 1.0:
		queue_free()
