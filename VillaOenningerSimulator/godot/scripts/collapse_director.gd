extends Node

signal progress_changed(percent: float)
signal collapse_started
signal shake_requested(amount: float)

var parts: Array = []
var started := false
var start_delay := 6.0
var wave_step := 0.22
var power := 1.0
var shock_origins: Array[Vector3] = []


func _ready() -> void:
	shock_origins = [
		Vector3(0, 7.5, 0),
		Vector3(-11, 2, 0),
		Vector3(11, 2, 0),
	]


func register(part: Node) -> void:
	if part != null and not parts.has(part):
		parts.append(part)


func total_parts() -> int:
	return parts.size()


func active_parts() -> int:
	var count := 0
	for p in parts:
		if is_instance_valid(p) and p.is_collapsing:
			count += 1
	return count


func start_collapse() -> void:
	if started:
		return
	started = true
	collapse_started.emit()
	_run()


func _run() -> void:
	await get_tree().create_timer(start_delay).timeout

	var ordered: Array = []
	for p in parts:
		if is_instance_valid(p):
			ordered.append(p)
	ordered.sort_custom(func(a, b): return a.global_position.y > b.global_position.y)

	var index := 0
	for part in ordered:
		if not is_instance_valid(part):
			continue
		part.collapse(_origin_for(index), power)
		index += 1
		progress_changed.emit(float(index) / maxf(1.0, float(ordered.size())) * 100.0)
		_spawn_dust(part.global_position)
		if index % 3 == 0:
			shake_requested.emit(0.16)
		await get_tree().create_timer(wave_step * randf_range(0.6, 1.4)).timeout


func _origin_for(index: int) -> Vector3:
	if shock_origins.size() > 0:
		return shock_origins[index % shock_origins.size()]
	return Vector3(0, -1, 0)


func _dust_texture() -> GradientTexture2D:
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 1))
	grad.set_color(1, Color(1, 1, 1, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64
	return tex


func _spawn_dust(pos: Vector3) -> void:
	var host := get_parent()
	if host == null:
		return

	var dust := CPUParticles3D.new()
	dust.name = "Dust"
	dust.amount = 26
	dust.lifetime = 3.4
	dust.one_shot = true
	dust.explosiveness = 0.95
	dust.direction = Vector3(0, 0.4, 0)
	dust.spread = 85.0
	dust.initial_velocity_min = 0.9
	dust.initial_velocity_max = 3.0
	dust.gravity = Vector3(0, -1.2, 0)
	dust.damping_min = 0.5
	dust.damping_max = 1.4
	dust.scale_amount_min = 0.25
	dust.scale_amount_max = 0.85
	dust.color = Color(0.62, 0.60, 0.56, 0.30)

	var quad := QuadMesh.new()
	quad.size = Vector2(0.8, 0.8)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.62, 0.60, 0.56, 0.30)
	mat.albedo_texture = _dust_texture()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.billboard_keep_scale = true
	quad.material = mat
	dust.mesh = quad

	host.add_child(dust)
	dust.global_position = pos
	dust.emitting = true
	dust.finished.connect(dust.queue_free)
