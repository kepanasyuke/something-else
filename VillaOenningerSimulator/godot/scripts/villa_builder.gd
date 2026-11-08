extends RefCounted

const COLLAPSE_PART := preload("res://scripts/collapse_part.gd")

var concrete: StandardMaterial3D
var concrete_dark: StandardMaterial3D
var concrete_warm: StandardMaterial3D
var glass: StandardMaterial3D
var glass_dark: StandardMaterial3D
var glass_car: StandardMaterial3D
var metal: StandardMaterial3D
var metal_light: StandardMaterial3D
var wood: StandardMaterial3D
var deck: StandardMaterial3D
var fabric: StandardMaterial3D
var water: StandardMaterial3D
var rock: StandardMaterial3D
var grass: StandardMaterial3D
var hedge: StandardMaterial3D
var robot_shell: StandardMaterial3D
var robot_silver: StandardMaterial3D
var robot_eye: StandardMaterial3D
var robot_core: StandardMaterial3D
var robot_seam: StandardMaterial3D
var robot_yellow: StandardMaterial3D
var robot_black: StandardMaterial3D
var robot_hose: StandardMaterial3D
var robot_beacon: StandardMaterial3D
var window_lit: StandardMaterial3D
var stone_trim: StandardMaterial3D
var brick: StandardMaterial3D
var globe_patina: StandardMaterial3D
var hero_leather: StandardMaterial3D
var hero_skin: StandardMaterial3D
var hero_hair: StandardMaterial3D
var hero_denim: StandardMaterial3D
var hero_boot: StandardMaterial3D
var hero_shirt: StandardMaterial3D
var hero_eye: StandardMaterial3D
var hero_iris: StandardMaterial3D
var hero_pupil: StandardMaterial3D
var hero_buckle: StandardMaterial3D
var warm_strip: StandardMaterial3D
var pool_light: StandardMaterial3D
var ripple: StandardMaterial3D
var headlight: StandardMaterial3D
var taillight: StandardMaterial3D
var car_body: StandardMaterial3D
var car_silver: StandardMaterial3D
var car_trim: StandardMaterial3D
var car_seat: StandardMaterial3D
var asphalt: StandardMaterial3D
var rubber: StandardMaterial3D
var cat_fur: StandardMaterial3D
var cat_dark: StandardMaterial3D

var director
var parts: Array = []


func _init() -> void:
	concrete = _mat(Color(0.46, 0.45, 0.42), 0.0, 0.80)
	concrete_dark = _mat(Color(0.13, 0.14, 0.16), 0.0, 0.82)
	concrete_warm = _mat(Color(0.36, 0.33, 0.29), 0.0, 0.76)
	glass = _glass(Color(0.30, 0.42, 0.52, 0.22))
	glass_dark = _glass(Color(0.05, 0.07, 0.10, 0.72))
	glass_car = _glass(Color(0.22, 0.28, 0.36, 0.58))
	glass_car.metallic = 0.55
	glass_car.roughness = 0.02
	metal = _mat(Color(0.22, 0.23, 0.26), 0.85, 0.35)
	metal_light = _mat(Color(0.42, 0.44, 0.47), 0.9, 0.25)
	wood = _mat(Color(0.30, 0.23, 0.17), 0.0, 0.7)
	deck = _mat(Color(0.24, 0.19, 0.15), 0.0, 0.82)
	fabric = _mat(Color(0.24, 0.21, 0.20), 0.0, 0.95)
	water = _glass(Color(0.05, 0.22, 0.30, 0.66))
	water.metallic = 0.35
	water.roughness = 0.03
	water.emission_enabled = true
	water.emission = Color(0.06, 0.24, 0.28)
	water.emission_energy_multiplier = 0.90
	ripple = _emissive(Color(0.42, 0.80, 0.92), 0.30)
	rock = _mat(Color(0.16, 0.16, 0.17), 0.0, 0.95)
	grass = _mat(Color(0.10, 0.15, 0.09), 0.0, 0.95)
	hedge = _mat(Color(0.16, 0.24, 0.13), 0.0, 0.92)
	robot_shell = _mat(Color(0.085, 0.090, 0.105), 0.7, 0.24)
	robot_silver = _mat(Color(0.58, 0.60, 0.63), 0.95, 0.22)
	robot_eye = _emissive(Color(0.40, 0.82, 1.0), 3.6)
	robot_core = _emissive(Color(0.30, 0.75, 1.0), 2.4)
	robot_seam = _emissive(Color(0.35, 0.70, 1.0), 1.3)
	robot_yellow = _mat(Color(0.86, 0.63, 0.05), 0.25, 0.42)
	robot_black = _mat(Color(0.055, 0.058, 0.065), 0.5, 0.4)
	robot_hose = _mat(Color(0.035, 0.035, 0.038), 0.0, 0.72)
	robot_beacon = _emissive(Color(1.0, 0.62, 0.10), 3.2)
	window_lit = _emissive(Color(1.0, 0.78, 0.48), 0.95)
	stone_trim = _mat(Color(0.62, 0.61, 0.57), 0.0, 0.66)
	brick = _mat(Color(0.33, 0.22, 0.19), 0.0, 0.88)
	globe_patina = _mat(Color(0.19, 0.26, 0.20), 0.40, 0.70)
	hero_leather = _mat(Color(0.095, 0.095, 0.105), 0.05, 0.68)
	hero_skin = _mat(Color(0.46, 0.32, 0.24), 0.0, 0.72)
	hero_hair = _mat(Color(0.06, 0.05, 0.045), 0.0, 0.85)
	hero_denim = _mat(Color(0.10, 0.12, 0.17), 0.0, 0.85)
	hero_boot = _mat(Color(0.05, 0.05, 0.06), 0.0, 0.7)
	hero_shirt = _mat(Color(0.16, 0.17, 0.19), 0.0, 0.9)
	hero_eye = _mat(Color(0.86, 0.86, 0.84), 0.0, 0.35)
	hero_iris = _mat(Color(0.20, 0.13, 0.08), 0.0, 0.25)
	hero_pupil = _mat(Color(0.04, 0.03, 0.03), 0.0, 0.3)
	hero_buckle = _mat(Color(0.42, 0.36, 0.22), 0.60, 0.52)
	warm_strip = _emissive(Color(1.0, 0.82, 0.55), 1.15)
	pool_light = _emissive(Color(0.30, 0.82, 0.92), 2.4)
	headlight = _emissive(Color(1.0, 0.96, 0.86), 4.0)
	taillight = _emissive(Color(1.0, 0.15, 0.10), 3.0)
	car_body = _mat(Color(0.07, 0.08, 0.10), 0.7, 0.25)
	car_silver = _mat(Color(0.55, 0.57, 0.60), 0.92, 0.18)
	car_trim = _mat(Color(0.14, 0.15, 0.17), 0.6, 0.42)
	car_seat = _mat(Color(0.10, 0.10, 0.12), 0.1, 0.78)
	asphalt = _mat(Color(0.10, 0.10, 0.11), 0.0, 0.9)
	rubber = _mat(Color(0.05, 0.05, 0.05), 0.0, 0.9)
	cat_fur = _mat(Color(0.72, 0.44, 0.20), 0.0, 0.9)
	cat_dark = _mat(Color(0.20, 0.14, 0.10), 0.0, 0.9)


func build(root: Node3D) -> void:
	_build_terrain(root)
	_build_villa(root)
	_build_sculpture(root)
	_build_terrace(root)
	_build_driveway(root)


func _mat(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metallic
	m.roughness = roughness
	return m


func _glass(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.metallic = 0.2
	m.roughness = 0.06
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m


func _emissive(color: Color, energy := 2.5) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	return m


func _globe_material() -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
uniform vec3 base_color : source_color = vec3(0.45, 0.34, 0.15);
uniform vec3 patina_color : source_color = vec3(0.16, 0.24, 0.20);
uniform sampler2D noise_tex : hint_default_white, filter_linear_mipmap;
uniform float patina_amount = 0.55;

void fragment() {
	float n = texture(noise_tex, UV * vec2(2.0, 1.4)).r;
	float m = smoothstep(0.46, 0.68, n);
	ALBEDO = mix(base_color, patina_color, m * patina_amount);
	METALLIC = mix(0.62, 0.16, m);
	ROUGHNESS = mix(0.72, 0.95, m);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh

	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.014
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.55

	var tex := NoiseTexture2D.new()
	tex.width = 512
	tex.height = 512
	tex.seamless = true
	tex.noise = noise
	mat.set_shader_parameter("noise_tex", tex)
	return mat


func mesh_box(size: Vector3, material: Material) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = box
	mi.material_override = material
	if material is StandardMaterial3D and material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


func mesh_sphere(radius: float, height: float, material: Material) -> MeshInstance3D:
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = height
	sphere.radial_segments = 16
	sphere.rings = 8
	var mi := MeshInstance3D.new()
	mi.mesh = sphere
	mi.material_override = material
	return mi


func _shape_box(size: Vector3) -> CollisionShape3D:
	var shape := BoxShape3D.new()
	shape.size = size
	var cs := CollisionShape3D.new()
	cs.shape = shape
	return cs


func static_box(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, material: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	body.add_child(mesh_box(size, material))
	body.add_child(_shape_box(size))
	parent.add_child(body)
	return body


func static_box_rot(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, rot_deg: Vector3, material: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	body.rotation_degrees = rot_deg
	body.add_child(mesh_box(size, material))
	body.add_child(_shape_box(size))
	parent.add_child(body)
	return body


func decor_box(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mi := mesh_box(size, material)
	mi.name = node_name
	mi.position = pos
	parent.add_child(mi)
	return mi


func decor_box_rot(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, rot_deg: Vector3, material: Material) -> MeshInstance3D:
	var mi := mesh_box(size, material)
	mi.name = node_name
	mi.position = pos
	mi.rotation_degrees = rot_deg
	parent.add_child(mi)
	return mi


func decor_cyl(parent: Node3D, node_name: String, pos: Vector3, radius: float, height: float, rot_deg: Vector3, material: Material) -> MeshInstance3D:
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = height
	cyl.radial_segments = 16
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = cyl
	mi.material_override = material
	mi.position = pos
	mi.rotation_degrees = rot_deg
	parent.add_child(mi)
	return mi


func _vary(material: Material, amount: float) -> Material:
	var src := material as StandardMaterial3D
	if src == null:
		return material
	var m := src.duplicate() as StandardMaterial3D
	var f := 1.0 + randf_range(-amount, amount)
	var c := src.albedo_color
	m.albedo_color = Color(clampf(c.r * f, 0.0, 1.0), clampf(c.g * f, 0.0, 1.0), clampf(c.b * f, 0.0, 1.0), c.a)
	m.roughness = clampf(src.roughness + randf_range(-0.08, 0.08), 0.05, 1.0)
	return m


func part_box(parent: Node3D, node_name: String, pos: Vector3, size: Vector3, material: Material) -> RigidBody3D:
	var body := RigidBody3D.new()
	body.set_script(COLLAPSE_PART)
	body.name = node_name
	body.position = pos
	body.freeze = true
	body.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	body.mass = clampf(size.x * size.y * size.z * 90.0, 12.0, 900.0)
	body.angular_damp = 0.4
	body.add_child(mesh_box(size, _vary(material, 0.14)))
	body.add_child(_shape_box(size))
	parent.add_child(body)
	parts.append(body)
	if director != null:
		director.register(body)
	return body


func _lamp(parent: Node3D, pos: Vector3, energy: float, color: Color, light_range: float) -> OmniLight3D:
	var lamp := OmniLight3D.new()
	lamp.position = pos
	lamp.light_energy = energy
	lamp.light_color = color
	lamp.omni_range = light_range
	parent.add_child(lamp)
	return lamp


func _build_terrain(root: Node3D) -> void:
	var plateau := static_box(root, "Plateau", Vector3(0, -0.6, 0), Vector3(110, 1.2, 52), grass)
	plateau.collision_layer = 1

	static_box(root, "Plateau_Rock", Vector3(0, -16, 0), Vector3(106, 32, 48), rock)

	var cliff := Node3D.new()
	cliff.name = "Cliff"
	root.add_child(cliff)
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261108
	for i in range(30):
		var sx := rng.randf_range(7.0, 14.0)
		var sy := rng.randf_range(10.0, 24.0)
		var sz := rng.randf_range(7.0, 14.0)
		var mi := mesh_box(Vector3(sx, sy, sz), rock)
		mi.name = "CliffBlock_%d" % i
		var along_z := i % 3 != 0
		var side := 1.0 if i % 2 == 0 else -1.0
		var y := -sy * 0.5 - rng.randf_range(4.0, 8.0)
		if along_z:
			mi.position = Vector3(rng.randf_range(-50.0, 50.0), y, side * rng.randf_range(19.0, 23.0))
		else:
			mi.position = Vector3(side * rng.randf_range(47.0, 51.0), y, rng.randf_range(-20.0, 20.0))
		mi.rotation_degrees = Vector3(0, rng.randf_range(0.0, 360.0), rng.randf_range(-8.0, 8.0))
		cliff.add_child(mi)

	var sea := mesh_box(Vector3(900, 0.6, 900), water)
	sea.name = "Sea"
	sea.position = Vector3(0, -24, 0)
	root.add_child(sea)


func _build_villa(root: Node3D) -> void:
	var villa := Node3D.new()
	villa.name = "Villa_Oenninger"
	root.add_child(villa)

	static_box(villa, "Slab_Ground", Vector3(0, -0.15, 0), Vector3(26, 0.3, 18), concrete)
	decor_box(villa, "Floor_Interior", Vector3(0, 0.03, 0), Vector3(25, 0.06, 17), wood)

	var column_x := [-12.0, -4.0, 4.0, 12.0]
	var column_z := [-8.0, 0.0, 8.0]
	for x in column_x:
		for z in column_z:
			static_box(villa, "Column_%d_%d" % [int(x), int(z)], Vector3(x, 2.1, z), Vector3(0.36, 4.2, 0.36), concrete)

	var win_mats: Array[StandardMaterial3D] = []
	for e in [1.05, 0.74, 0.52, 0.90, 0.44, 0.82]:
		win_mats.append(_emissive(Color(1.0, 0.76, 0.46), e))

	var index := 0
	for x in [-10.9, -6.55, -2.2, 2.2, 6.55, 10.9]:
		decor_box(villa, "Pier_S_%d" % index, Vector3(x + 2.18, 4.3, -9.0), Vector3(0.55, 8.6, 0.5), brick)
		part_box(villa, "Window_S_G_%d" % index, Vector3(x, 2.55, -8.92), Vector3(3.7, 3.3, 0.12), win_mats[index])
		part_box(villa, "Window_S_F1_%d" % index, Vector3(x, 6.85, -8.92), Vector3(3.7, 3.1, 0.12), win_mats[(index + 3) % 6])
		decor_box(villa, "WinBarH_S_G_%d" % index, Vector3(x, 2.55, -8.84), Vector3(3.72, 0.07, 0.1), concrete_dark)
		decor_box(villa, "WinBarH_S_F1_%d" % index, Vector3(x, 6.85, -8.84), Vector3(3.72, 0.07, 0.1), concrete_dark)
		decor_box(villa, "Sill_S_G_%d" % index, Vector3(x, 0.82, -9.05), Vector3(3.9, 0.18, 0.34), stone_trim)
		decor_box(villa, "Sill_S_F1_%d" % index, Vector3(x, 5.22, -9.05), Vector3(3.9, 0.18, 0.34), stone_trim)
		decor_box(villa, "Lintel_S_G_%d" % index, Vector3(x, 4.28, -9.05), Vector3(3.9, 0.22, 0.34), stone_trim)
		decor_box(villa, "Lintel_S_F1_%d" % index, Vector3(x, 8.45, -9.05), Vector3(3.9, 0.22, 0.34), stone_trim)
		decor_box(villa, "WinBar_S_G_%d" % index, Vector3(x, 2.55, -8.86), Vector3(0.08, 3.3, 0.1), stone_trim)
		decor_box(villa, "WinBar_S_F1_%d" % index, Vector3(x, 6.85, -8.86), Vector3(0.08, 3.1, 0.1), stone_trim)
		index += 1

	decor_box(villa, "Plinth_S", Vector3(0, 0.55, -9.25), Vector3(26.4, 1.1, 0.6), stone_trim)
	decor_box(villa, "Cornice_S", Vector3(0, 8.05, -9.3), Vector3(26.6, 0.4, 0.7), stone_trim)

	for i in range(5):
		decor_box(villa, "RustG_%d" % i, Vector3(0, 0.24 + i * 0.15, -9.32), Vector3(26.2, 0.05, 0.14), concrete_dark)
	for i in range(26):
		decor_box(villa, "Dentil_%d" % i, Vector3(-12.5 + i * 1.0, 7.80, -9.40), Vector3(0.34, 0.26, 0.18), stone_trim)
	for i in range(13):
		var qy := 0.86 + i * 0.62
		var qw := 0.92 if i % 2 == 0 else 0.62
		decor_box(villa, "QuoinE_%d" % i, Vector3(13.28, qy, -8.72), Vector3(0.42, 0.5, qw), stone_trim)
		decor_box(villa, "QuoinW_%d" % i, Vector3(-13.28, qy, -8.72), Vector3(0.42, 0.5, qw), stone_trim)
	for jx in [-10.9, -6.55, -2.2, 2.2, 6.55, 10.9]:
		for side in [-1.0, 1.0]:
			decor_box(villa, "JambG_%d_%d" % [int(jx * 10.0), int(side)], Vector3(jx + 1.95 * side, 2.55, -9.06), Vector3(0.18, 3.5, 0.26), stone_trim)
			decor_box(villa, "JambF1_%d_%d" % [int(jx * 10.0), int(side)], Vector3(jx + 1.95 * side, 6.85, -9.06), Vector3(0.18, 3.3, 0.26), stone_trim)
		decor_box(villa, "KeyStone_%d" % int(jx * 10.0), Vector3(jx, 4.42, -9.02), Vector3(0.46, 0.34, 0.3), stone_trim)

	static_box(villa, "Portico_Step0", Vector3(0, 0.09, -10.5), Vector3(24.5, 0.18, 4.0), stone_trim)
	static_box(villa, "Portico_Step1", Vector3(0, 0.28, -10.15), Vector3(23.5, 0.2, 3.4), stone_trim)
	decor_box(villa, "Portico_Deck", Vector3(0, 0.40, -10.4), Vector3(23.0, 0.1, 3.2), stone_trim)

	var portico_x := [-10.4, -6.24, -2.08, 2.08, 6.24, 10.4]
	index = 0
	for cx in portico_x:
		part_box(villa, "PorticoColumn_%d" % index, Vector3(cx, 4.2, -11.4), Vector3(0.66, 7.55, 0.66), stone_trim)
		decor_box(villa, "PorticoBase_%d" % index, Vector3(cx, 0.55, -11.4), Vector3(0.86, 0.36, 0.86), stone_trim)
		decor_box(villa, "PorticoCapital_%d" % index, Vector3(cx, 7.85, -11.4), Vector3(0.92, 0.32, 0.92), stone_trim)
		index += 1

	index = 0
	for i in range(8):
		for j in range(2):
			var ex := -10.22 + 2.923 * i
			var ez := -11.4 + 1.70 * j
			part_box(villa, "Entablature_%d" % index, Vector3(ex, 8.25, ez), Vector3(2.86, 1.05, 1.64), stone_trim)
			index += 1
	decor_box(villa, "Portico_Frieze", Vector3(0, 8.25, -12.28), Vector3(23.4, 0.5, 0.14), concrete_warm)

	var pediment := PrismMesh.new()
	pediment.size = Vector3(23.4, 1.95, 3.4)
	pediment.left_to_right = true
	var ped := MeshInstance3D.new()
	ped.name = "Portico_Pediment"
	ped.mesh = pediment
	ped.material_override = stone_trim
	ped.position = Vector3(0, 9.75, -10.55)
	ped.rotation_degrees = Vector3(0, 0, 0)
	villa.add_child(ped)
	decor_box(villa, "Pediment_Shadow", Vector3(0, 9.55, -12.24), Vector3(19.0, 1.1, 0.12), concrete_warm)

	for i in range(4):
		decor_cyl(villa, "Portico_Lamp_%d" % i, Vector3(-7.8 + i * 5.2, 1.15, -12.1), 0.09, 0.3, Vector3.ZERO, robot_beacon)
		_lamp(villa, Vector3(-7.8 + i * 5.2, 1.3, -12.0), 1.15, Color(1.0, 0.80, 0.52), 10.0)

	index = 0
	for z in [-6.75, -2.25, 2.25, 6.75]:
		part_box(villa, "Glass_E_G_%d" % index, Vector3(13.0, 2.1, z), Vector3(0.09, 4.0, 4.5), glass)
		part_box(villa, "Glass_E_F1_%d" % index, Vector3(13.0, 6.4, z), Vector3(0.09, 4.1, 4.5), glass)
		part_box(villa, "Glass_W_G_%d" % index, Vector3(-13.0, 2.1, z), Vector3(0.09, 4.0, 4.5), glass)
		part_box(villa, "Glass_W_F1_%d" % index, Vector3(-13.0, 6.4, z), Vector3(0.09, 4.1, 4.5), glass)
		index += 1

	index = 0
	for x in [-11.15, -7.45, -3.75, 3.75, 7.45, 11.15]:
		part_box(villa, "Glass_N_G_%d" % index, Vector3(x, 2.1, 9.0), Vector3(3.2, 4.0, 0.09), glass)
		part_box(villa, "Wall_N_F1_%d" % index, Vector3(x, 6.4, 9.0), Vector3(3.73, 4.1, 0.35), concrete)
		index += 1

	part_box(villa, "Wall_W_G_0", Vector3(-13.0, 2.1, -4.45), Vector3(0.35, 4.2, 8.9), concrete)
	part_box(villa, "Wall_W_G_1", Vector3(-13.0, 2.1, 4.45), Vector3(0.35, 4.2, 8.9), concrete)

	part_box(villa, "Partition_1", Vector3(-6.0, 1.15, 2.0), Vector3(0.25, 2.3, 8.0), concrete_warm)
	part_box(villa, "Partition_2", Vector3(-3.5, 2.1, -3.0), Vector3(3.0, 4.2, 0.25), concrete_warm)
	part_box(villa, "Partition_3", Vector3(4.0, 6.4, 3.0), Vector3(0.25, 4.1, 7.0), concrete_warm)

	for lx in [-7.0, 2.0, 9.0]:
		_lamp(villa, Vector3(lx, 3.7, 0), 2.6, Color(1.0, 0.85, 0.68), 13.0)
	for lx in [-7.0, 2.0, 9.0]:
		_lamp(villa, Vector3(lx, 7.9, 0), 2.0, Color(1.0, 0.85, 0.68), 12.0)
	for lz in [-6.0, 0.0, 6.0]:
		_lamp(villa, Vector3(7.0, 2.4, lz), 1.35, Color(1.0, 0.82, 0.62), 10.0)

	decor_box(villa, "CeilingStrip_G", Vector3(0, 4.08, 0), Vector3(24.0, 0.05, 0.05), warm_strip)
	decor_box(villa, "CeilingStrip_F1", Vector3(0, 8.42, 0), Vector3(24.0, 0.05, 0.05), warm_strip)

	for i in range(15):
		decor_box(villa, "Stair_%d" % i, Vector3(8.4, 0.14 + i * 0.28, -1.2 + i * 0.6), Vector3(3.4, 0.16, 0.6), wood)
	static_box_rot(villa, "StairRamp", Vector3(8.4, 2.175, 3.3), Vector3(3.3, 0.2, 10.05), Vector3(-25.8, 0, 0), metal)
	decor_box(villa, "Stair_Rail", Vector3(10.1, 2.2, 3.0), Vector3(0.08, 4.4, 0.08), metal)

	var slab_i := 0
	for sx in range(4):
		for sz in range(4):
			var tile_pos := Vector3(-13.0 + 4.875 * (sx + 0.5), 4.2, -9.0 + 4.5 * (sz + 0.5))
			part_box(villa, "Slab_L1_%d" % slab_i, tile_pos, Vector3(4.80, 0.3, 4.45), concrete)
			slab_i += 1
	part_box(villa, "Slab_L1_West", Vector3(11.75, 4.2, 0.0), Vector3(2.5, 0.3, 18.0), concrete)
	part_box(villa, "Slab_L1_Front", Vector3(8.5, 4.2, -5.1), Vector3(4.0, 0.3, 7.8), concrete)
	part_box(villa, "Slab_L1_Back", Vector3(8.5, 4.2, 8.4), Vector3(4.0, 0.3, 1.2), concrete)

	decor_box(villa, "Band_S", Vector3(0, 4.2, -9.35), Vector3(26.6, 0.5, 0.35), concrete)
	decor_box(villa, "Band_E", Vector3(13.35, 4.2, 0.0), Vector3(0.35, 0.5, 18.6), concrete)
	decor_box(villa, "Band_W", Vector3(-13.35, 4.2, 0.0), Vector3(0.35, 0.5, 18.6), concrete)
	decor_box(villa, "Band_N", Vector3(0, 4.2, 9.35), Vector3(26.6, 0.5, 0.35), concrete)

	index = 0
	for i in range(6):
		for j in range(4):
			var rx := -11.25 + 4.5 * i
			var rz := -7.125 + 4.75 * j
			part_box(villa, "Roof_%d" % index, Vector3(rx, 8.6, rz), Vector3(4.42, 0.35, 4.65), concrete_dark)
			index += 1

	var rim_i := 0
	for i in range(4):
		part_box(villa, "RoofRim_S_%d" % rim_i, Vector3(-10.1 + 6.73 * i, 8.92, -9.42), Vector3(6.68, 0.44, 0.42), concrete_dark)
		part_box(villa, "RoofRim_N_%d" % rim_i, Vector3(-10.1 + 6.73 * i, 8.92, 9.42), Vector3(6.68, 0.44, 0.42), concrete_dark)
		rim_i += 1
	for i in range(3):
		part_box(villa, "RoofRim_W_%d" % i, Vector3(-13.42, 8.92, -6.24 + 6.24 * i), Vector3(0.42, 0.44, 6.06), concrete_dark)
		part_box(villa, "RoofRim_E_%d" % i, Vector3(13.42, 8.92, -6.24 + 6.24 * i), Vector3(0.42, 0.44, 6.06), concrete_dark)

	var eave_i := 0
	for i in range(4):
		var ex := -10.5 + 7.0 * i
		part_box(villa, "Eave_S_%d" % i, Vector3(ex, 8.62, -9.9), Vector3(6.90, 0.3, 1.4), concrete)
		part_box(villa, "Eave_N_%d" % i, Vector3(ex, 8.62, 9.9), Vector3(6.90, 0.3, 1.4), concrete)
		eave_i += 1
	for i in range(3):
		var ez := -6.0 + 6.0 * i
		part_box(villa, "Eave_E_%d" % i, Vector3(13.9, 8.62, ez), Vector3(1.4, 0.3, 5.90), concrete)
		part_box(villa, "Eave_W_%d" % i, Vector3(-13.9, 8.62, ez), Vector3(1.4, 0.3, 5.90), concrete)

	decor_box(villa, "EaveStrip_S", Vector3(0, 8.42, -9.2), Vector3(27.0, 0.06, 0.06), warm_strip)
	decor_box(villa, "EaveStrip_N", Vector3(0, 8.42, 9.2), Vector3(27.0, 0.06, 0.06), warm_strip)

	for i in range(6):
		decor_box(villa, "Column_Glass_%d" % i, Vector3(-8.0 + i * 3.2, 4.5, -9.05), Vector3(0.22, 4.2, 0.22), metal_light)

	part_box(villa, "Sofa_Seat", Vector3(-9.0, 0.32, 1.5), Vector3(2.6, 0.44, 0.9), fabric)
	part_box(villa, "Sofa_Back", Vector3(-9.0, 0.74, 1.05), Vector3(2.6, 0.6, 0.2), fabric)
	part_box(villa, "Coffee_Table", Vector3(-9.0, 0.30, 3.4), Vector3(1.8, 0.10, 0.9), wood)
	part_box(villa, "Dining_Table", Vector3(-1.5, 0.44, 4.6), Vector3(2.8, 0.10, 1.1), wood)
	part_box(villa, "Chair_0", Vector3(-2.6, 0.30, 3.6), Vector3(0.45, 0.5, 0.45), fabric)
	part_box(villa, "Chair_1", Vector3(-0.4, 0.30, 3.6), Vector3(0.45, 0.5, 0.45), fabric)
	part_box(villa, "Chair_2", Vector3(-2.6, 0.30, 5.6), Vector3(0.45, 0.5, 0.45), fabric)
	part_box(villa, "Chair_3", Vector3(-0.4, 0.30, 5.6), Vector3(0.45, 0.5, 0.45), fabric)
	part_box(villa, "Kitchen_Island", Vector3(6.0, 0.45, 4.6), Vector3(3.2, 0.9, 1.0), concrete_warm)
	decor_box(villa, "Rug", Vector3(0.0, 0.05, 0.5), Vector3(6.0, 0.02, 5.0), fabric)

	part_box(villa, "Bed", Vector3(-9.0, 4.62, 2.0), Vector3(2.2, 0.45, 2.6), fabric)
	part_box(villa, "Bed_Head", Vector3(-9.0, 4.9, 0.65), Vector3(2.2, 1.0, 0.15), wood)
	part_box(villa, "Wardrobe", Vector3(5.5, 5.4, 5.0), Vector3(2.0, 2.0, 0.7), wood)
	part_box(villa, "Desk", Vector3(3.0, 4.95, -5.5), Vector3(2.0, 0.10, 0.9), wood)

	for i in range(2):
		var pz := 1.55 + i * 0.9
		decor_box(villa, "SofaCushion_%d" % i, Vector3(-9.0, 0.50, pz), Vector3(1.24, 0.14, 0.82), fabric)
		decor_box(villa, "SofaPillow_%d" % i, Vector3(-9.0 + (-0.75 if i == 0 else 0.75), 0.70, 1.10), Vector3(0.42, 0.42, 0.16), concrete_warm)
		decor_box(villa, "SofaFoot_%d" % i, Vector3(-9.0 + (-1.1 if i == 0 else 1.1), 0.08, 1.5), Vector3(0.12, 0.16, 0.7), metal)
	decor_box(villa, "CoffeeTray", Vector3(-9.0, 0.36, 3.4), Vector3(0.5, 0.03, 0.35), metal_light)

	decor_box(villa, "TV_Panel", Vector3(12.5, 2.40, 0.0), Vector3(0.06, 1.30, 2.20), glass_dark)
	decor_box(villa, "TV_Screen", Vector3(12.44, 2.40, 0.0), Vector3(0.03, 1.10, 2.00), _emissive(Color(0.30, 0.55, 0.85), 0.55))
	decor_box(villa, "TV_Shelf", Vector3(12.6, 0.55, 0.0), Vector3(0.5, 0.08, 2.6), wood)

	decor_box(villa, "Bookshelf", Vector3(-11.6, 1.30, -4.6), Vector3(0.45, 2.60, 2.20), wood)
	for i in range(4):
		decor_box(villa, "BookRow_%d" % i, Vector3(-11.42, 0.55 + i * 0.52, -4.6), Vector3(0.24, 0.30, 1.9), concrete_warm)

	decor_box(villa, "Kitchen_Front", Vector3(6.0, 0.45, 5.25), Vector3(3.2, 0.9, 0.30), wood)
	decor_box(villa, "Kitchen_Top", Vector3(6.0, 0.94, 4.9), Vector3(3.3, 0.06, 1.05), stone_trim)
	decor_box(villa, "Kitchen_Sink", Vector3(5.4, 0.92, 4.66), Vector3(0.72, 0.05, 0.5), metal)
	for i in range(2):
		decor_cyl(villa, "BarStool_%d" % i, Vector3(4.6 + i * 1.1, 0.32, 3.5), 0.20, 0.06, Vector3.ZERO, wood)
		decor_cyl(villa, "BarStoolPost_%d" % i, Vector3(4.6 + i * 1.1, 0.16, 3.5), 0.04, 0.32, Vector3.ZERO, metal)

	for i in range(3):
		decor_cyl(villa, "Pot_%d" % i, Vector3(-12.2 + i * 1.5, 0.18, -7.6), 0.20, 0.36, Vector3.ZERO, concrete_warm)
		var bush := mesh_sphere(0.30, 0.60, grass)
		bush.name = "Plant_%d" % i
		bush.position = Vector3(-12.2 + i * 1.5, 0.55, -7.6)
		villa.add_child(bush)

	decor_cyl(villa, "DiningPendant", Vector3(-1.5, 3.35, 4.6), 0.26, 0.24, Vector3.ZERO, warm_strip)
	decor_cyl(villa, "DiningPendantStem", Vector3(-1.5, 3.65, 4.6), 0.02, 0.8, Vector3.ZERO, metal)
	_lamp(villa, Vector3(-1.5, 3.2, 4.6), 1.1, Color(1.0, 0.82, 0.58), 7.0)

	decor_box(villa, "BedPillowL", Vector3(-9.7, 4.90, 1.05), Vector3(0.72, 0.16, 0.42), concrete)
	decor_box(villa, "BedPillowR", Vector3(-8.3, 4.90, 1.05), Vector3(0.72, 0.16, 0.42), concrete)
	decor_box(villa, "BedThrow", Vector3(-9.0, 4.88, 2.70), Vector3(2.24, 0.10, 1.10), concrete_warm)
	decor_box(villa, "Nightstand", Vector3(-10.5, 4.55, 0.85), Vector3(0.55, 0.55, 0.55), wood)
	decor_cyl(villa, "NightLamp", Vector3(-10.5, 4.95, 0.85), 0.10, 0.24, Vector3.ZERO, warm_strip)

	decor_box(villa, "DeskChair", Vector3(3.0, 4.62, -4.6), Vector3(0.52, 0.10, 0.52), fabric)
	decor_box(villa, "DeskChairBack", Vector3(3.0, 4.90, -4.32), Vector3(0.52, 0.50, 0.08), fabric)
	decor_box(villa, "Laptop", Vector3(3.0, 5.02, -5.5), Vector3(0.44, 0.03, 0.30), metal)
	decor_box(villa, "LaptopLid", Vector3(2.80, 5.14, -5.5), Vector3(0.03, 0.26, 0.30), metal_light)

	_lamp(villa, Vector3(-11.5, 1.0, -9.8), 0.7, Color(1.0, 0.84, 0.62), 9.0)
	_lamp(villa, Vector3(11.5, 1.0, -9.8), 0.7, Color(1.0, 0.84, 0.62), 9.0)
	_lamp(villa, Vector3(-11.5, 1.0, 9.8), 0.7, Color(1.0, 0.84, 0.62), 9.0)
	_lamp(villa, Vector3(11.5, 1.0, 9.8), 0.7, Color(1.0, 0.84, 0.62), 9.0)


func _build_sculpture(root: Node3D) -> void:
	var sculpt := Node3D.new()
	sculpt.name = "Globe_Sculpture"
	root.add_child(sculpt)

	var cx := 7.9
	var cz := -14.8

	static_box(sculpt, "Globe_Base", Vector3(cx, 0.16, cz), Vector3(3.6, 0.32, 3.6), concrete_dark)
	part_box(sculpt, "Globe_Plinth", Vector3(cx, 0.86, cz), Vector3(1.9, 1.08, 1.9), concrete_warm)
	decor_box(sculpt, "Globe_PlinthCap", Vector3(cx, 1.42, cz), Vector3(2.1, 0.14, 2.1), concrete_dark)

	var globe := mesh_sphere(1.45, 2.9, _globe_material())
	globe.name = "Globe_Sphere"
	globe.position = Vector3(cx, 2.86, cz)
	sculpt.add_child(globe)

	decor_cyl(sculpt, "Globe_Band", Vector3(cx, 2.86, cz), 1.50, 0.13, Vector3.ZERO, globe_patina)
	decor_cyl(sculpt, "Globe_Pole", Vector3(cx, 4.32, cz), 0.09, 0.16, Vector3.ZERO, globe_patina)


	_lamp(sculpt, Vector3(cx, 0.55, cz - 2.3), 0.9, Color(1.0, 0.80, 0.52), 9.0)
	_lamp(sculpt, Vector3(cx, 3.6, cz + 2.2), 1.1, Color(1.0, 0.78, 0.48), 7.0)


func _build_terrace(root: Node3D) -> void:
	var terrace := Node3D.new()
	terrace.name = "Terrace"
	root.add_child(terrace)

	var tslab_i := 0
	for i in range(6):
		for j in range(3):
			var tx := -12.5 + 5.0 * i
			var tz := 12.17 + 3.33 * j
			part_box(terrace, "Terrace_Slab_%d" % tslab_i, Vector3(tx, -0.16, tz), Vector3(4.90, 0.32, 3.25), concrete)
			tslab_i += 1
	decor_box(terrace, "Terrace_Deck", Vector3(0, 0.01, 14.0), Vector3(29.6, 0.04, 9.6), deck)

	decor_box(terrace, "Pool_Water", Vector3(-7, 0.06, 14.0), Vector3(7, 0.1, 7.4), water)
	decor_box(terrace, "Pool_Bottom", Vector3(-7, -0.12, 14.0), Vector3(6.8, 0.04, 7.2), pool_light)
	decor_box(terrace, "Pool_Wall_N", Vector3(-7, -0.02, 10.45), Vector3(6.8, 0.26, 0.5), pool_light)
	decor_box(terrace, "Pool_Wall_S", Vector3(-7, -0.02, 17.55), Vector3(6.8, 0.26, 0.5), pool_light)
	decor_box(terrace, "Pool_Wall_E", Vector3(-3.9, -0.02, 14.0), Vector3(0.5, 0.26, 6.6), pool_light)
	decor_box(terrace, "Pool_Wall_W", Vector3(-10.1, -0.02, 14.0), Vector3(0.5, 0.26, 6.6), pool_light)
	for i in range(5):
		decor_box(terrace, "Pool_Ripple_%d" % i, Vector3(-9.6 + i * 1.35, 0.115, 12.4 + (i % 3) * 1.7), Vector3(0.9, 0.01, 0.06), ripple)
	static_box(terrace, "Pool_Rim_N", Vector3(-7, 0.06, 10.1), Vector3(7.4, 0.12, 0.4), concrete_dark)
	static_box(terrace, "Pool_Rim_S", Vector3(-7, 0.06, 17.9), Vector3(7.4, 0.12, 0.4), concrete_dark)
	_lamp(terrace, Vector3(-7, -0.1, 14.0), 3.2, Color(0.32, 0.82, 0.95), 11.0)

	for i in range(9):
		var x := -12.0 + i * 3.0
		part_box(terrace, "Railing_S_%d" % i, Vector3(x, 0.7, 18.9), Vector3(2.9, 1.1, 0.05), glass)
		decor_box(terrace, "RailingTop_S_%d" % i, Vector3(x, 1.29, 18.9), Vector3(2.94, 0.07, 0.09), metal_light)
	for i in range(3):
		var z := 10.5 + i * 3.0
		part_box(terrace, "Railing_E_%d" % i, Vector3(14.9, 0.7, z), Vector3(0.05, 1.1, 2.9), glass)
		part_box(terrace, "Railing_W_%d" % i, Vector3(-14.9, 0.7, z), Vector3(0.05, 1.1, 2.9), glass)
		decor_box(terrace, "RailingTop_E_%d" % i, Vector3(14.9, 1.29, z), Vector3(0.09, 0.07, 2.94), metal_light)
		decor_box(terrace, "RailingTop_W_%d" % i, Vector3(-14.9, 1.29, z), Vector3(0.09, 0.07, 2.94), metal_light)
	for i in range(11):
		decor_cyl(terrace, "RailPost_%d" % i, Vector3(-15.0 + i * 3.0, 0.66, 18.9), 0.035, 1.32, Vector3.ZERO, metal_light)
	for i in range(13):
		decor_box(terrace, "DeckPlank_%d" % i, Vector3(-12.0 + i * 2.0, 0.035, 14.0), Vector3(0.06, 0.02, 9.5), concrete_dark)

	part_box(terrace, "Lounger_0", Vector3(3.0, 0.22, 16.5), Vector3(2.0, 0.22, 0.8), fabric)
	part_box(terrace, "Lounger_1", Vector3(6.0, 0.22, 16.5), Vector3(2.0, 0.22, 0.8), fabric)
	part_box(terrace, "Terrace_Table", Vector3(4.5, 0.35, 12.5), Vector3(1.4, 0.08, 0.9), wood)

	for i in range(2):
		var lx := 3.0 + i * 3.0
		decor_box(terrace, "LoungerFrame_%d" % i, Vector3(lx, 0.10, 16.5), Vector3(2.06, 0.07, 0.84), metal)
		for corner in [[-0.92, -0.36], [0.92, -0.36], [-0.92, 0.36], [0.92, 0.36]]:
			decor_box(terrace, "LoungerLeg_%d_%d_%d" % [i, int(corner[0] * 10.0), int(corner[1] * 10.0)], Vector3(lx + corner[0], 0.06, 16.5 + corner[1]), Vector3(0.07, 0.12, 0.07), metal)
		decor_box_rot(terrace, "LoungerBack_%d" % i, Vector3(lx - 0.78, 0.42, 16.5), Vector3(0.62, 0.22, 0.78), Vector3(0, 0, -52), fabric)
		decor_box(terrace, "LoungerPillow_%d" % i, Vector3(lx - 0.72, 0.50, 16.5), Vector3(0.34, 0.12, 0.6), concrete)
		decor_box(terrace, "SideTable_%d" % i, Vector3(lx + 1.35, 0.30, 16.5), Vector3(0.42, 0.06, 0.42), wood)
		decor_cyl(terrace, "SideTableLeg_%d" % i, Vector3(lx + 1.35, 0.16, 16.5), 0.05, 0.30, Vector3.ZERO, metal)

	decor_cyl(terrace, "Umbrella_Pole", Vector3(4.5, 1.25, 12.5), 0.045, 2.5, Vector3.ZERO, metal)
	var canopy := CylinderMesh.new()
	canopy.top_radius = 0.07
	canopy.bottom_radius = 1.6
	canopy.height = 0.34
	canopy.radial_segments = 14
	var canopy_mi := MeshInstance3D.new()
	canopy_mi.name = "Umbrella_Canopy"
	canopy_mi.mesh = canopy
	canopy_mi.material_override = fabric
	canopy_mi.position = Vector3(4.5, 2.42, 12.5)
	terrace.add_child(canopy_mi)
	decor_cyl(terrace, "Umbrella_Tip", Vector3(4.5, 2.66, 12.5), 0.05, 0.14, Vector3.ZERO, metal)

	for i in range(4):
		var cx := -1.4 if i < 2 else 1.4
		var cz := 11.6 if i % 2 == 0 else 13.4
		decor_box(terrace, "DeckChairSeat_%d" % i, Vector3(cx, 0.24, cz), Vector3(0.52, 0.08, 0.52), wood)
		decor_box(terrace, "DeckChairBack_%d" % i, Vector3(cx + (0.24 if cx > 0.0 else -0.24), 0.46, cz), Vector3(0.06, 0.56, 0.52), wood)
		for corner in [[-0.2, -0.2], [0.2, -0.2], [-0.2, 0.2], [0.2, 0.2]]:
			decor_box(terrace, "DeckChairLeg_%d_%d_%d" % [i, int(corner[0] * 10.0), int(corner[1] * 10.0)], Vector3(cx + corner[0], 0.10, cz + corner[1]), Vector3(0.05, 0.14, 0.05), wood)

	part_box(terrace, "BBQ_Counter", Vector3(12.6, 0.48, 11.4), Vector3(2.2, 0.9, 0.9), concrete_warm)
	decor_box(terrace, "BBQ_Grill", Vector3(12.6, 0.96, 11.4), Vector3(1.0, 0.10, 0.62), metal)
	decor_box(terrace, "BBQ_Lid", Vector3(12.6, 1.06, 11.2), Vector3(1.0, 0.10, 0.22), metal_light)

	for i in range(5):
		var px := -13.2 + i * 6.6
		static_box(terrace, "Planter_%d" % i, Vector3(px, 0.30, 19.35), Vector3(1.5, 0.6, 0.5), concrete_warm)
		decor_box(terrace, "Hedge_%d" % i, Vector3(px, 0.78, 19.35), Vector3(1.4, 0.42, 0.44), hedge)

	decor_cyl(terrace, "PoolLadder_L", Vector3(-3.4, 0.45, 10.3), 0.03, 0.9, Vector3.ZERO, metal_light)
	decor_cyl(terrace, "PoolLadder_R", Vector3(-2.9, 0.45, 10.3), 0.03, 0.9, Vector3.ZERO, metal_light)
	decor_box(terrace, "PoolStep_0", Vector3(-7.0, 0.02, 10.6), Vector3(6.6, 0.06, 0.7), stone_trim)
	decor_box(terrace, "PoolStep_1", Vector3(-7.0, -0.16, 11.3), Vector3(6.6, 0.06, 0.7), stone_trim)

	for i in range(5):
		decor_box(terrace, "DeckStrip_%d" % i, Vector3(-14.0 + i * 7.0, 0.03, 18.6), Vector3(2.0, 0.05, 0.05), warm_strip)
		_lamp(terrace, Vector3(-13.0 + i * 6.5, 2.2, 12.0), 3.0, Color(1.0, 0.84, 0.62), 17.0)
	for i in range(4):
		_lamp(terrace, Vector3(-10.5 + i * 7.0, 1.9, 18.2), 2.0, Color(1.0, 0.84, 0.62), 13.0)


func _build_driveway(root: Node3D) -> void:
	var road := static_box_rot(root, "Driveway", Vector3(-30, 0.02, -20), Vector3(40, 0.08, 7), Vector3(0, -22, 0), asphalt)
	road.collision_layer = 1
	static_box(root, "Entrance_Plaza", Vector3(-17, -0.05, -14), Vector3(14, 0.1, 10), concrete_dark)

	for i in range(5):
		var pos := Vector3(-12.0 - i * 3.4, 0.9, -10.6 + i * 0.2)
		decor_box(root, "Bollard_%d" % i, pos, Vector3(0.12, 1.8, 0.12), metal)
		var cap := decor_box(root, "BollardCap_%d" % i, pos + Vector3(0, 0.95, 0), Vector3(0.16, 0.12, 0.16), warm_strip)
		cap.name = "BollardCap_%d" % i
		_lamp(root, pos + Vector3(0, 1.1, 0), 1.1, Color(1.0, 0.85, 0.6), 7.0)

	for i in range(3):
		var post := Vector3(-11.5 - i * 7.0, 0.0, -11.2)
		decor_box(root, "LampPost_%d" % i, post + Vector3(0, 2.2, 0), Vector3(0.16, 4.4, 0.16), metal)
		decor_box(root, "LampHead_%d" % i, post + Vector3(0, 4.5, 0), Vector3(0.5, 0.16, 0.5), warm_strip)
		_lamp(root, post + Vector3(0, 4.36, 0), 3.5, Color(1.0, 0.86, 0.62), 18.0)


func make_car() -> Node3D:
	var car := Node3D.new()
	car.name = "Spooner_Car"
	car.position = Vector3(-46, 0.05, -26)

	decor_box(car, "Car_Underbody", Vector3(0.0, 0.22, 0.0), Vector3(2.70, 0.12, 1.28), rubber)

	var hull := mesh_sphere(1.0, 2.0, car_silver)
	hull.name = "Car_Hull"
	hull.position = Vector3(0.0, 0.62, 0.0)
	hull.scale = Vector3(2.00, 0.34, 1.02)
	car.add_child(hull)

	var nose := mesh_sphere(1.0, 2.0, car_silver)
	nose.name = "Car_Nose"
	nose.position = Vector3(1.62, 0.46, 0.0)
	nose.scale = Vector3(0.46, 0.18, 0.62)
	car.add_child(nose)

	var tail := mesh_sphere(1.0, 2.0, car_silver)
	tail.name = "Car_Tail"
	tail.position = Vector3(-1.62, 0.54, 0.0)
	tail.scale = Vector3(0.44, 0.26, 0.74)
	car.add_child(tail)

	var skirt := mesh_sphere(1.0, 2.0, car_body)
	skirt.name = "Car_Skirt"
	skirt.position = Vector3(0.0, 0.44, 0.0)
	skirt.scale = Vector3(1.94, 0.30, 0.95)
	car.add_child(skirt)

	var canopy := mesh_sphere(1.0, 2.0, glass_car)
	canopy.name = "Car_Canopy"
	canopy.position = Vector3(-0.20, 0.92, 0.0)
	canopy.scale = Vector3(1.10, 0.22, 0.74)
	car.add_child(canopy)

	decor_box(car, "Car_CanopyRimL", Vector3(-0.20, 0.880, 0.720), Vector3(1.86, 0.04, 0.06), car_silver)
	decor_box(car, "Car_CanopyRimR", Vector3(-0.20, 0.880, -0.720), Vector3(1.86, 0.04, 0.06), car_silver)
	decor_box(car, "Car_CabinTrimL", Vector3(-0.20, 0.860, 0.700), Vector3(1.70, 0.05, 0.05), car_trim)
	decor_box(car, "Car_CabinTrimR", Vector3(-0.20, 0.860, -0.700), Vector3(1.70, 0.05, 0.05), car_trim)

	decor_box(car, "Car_Splitter", Vector3(1.94, 0.280, 0.0), Vector3(0.24, 0.04, 0.92), car_trim)
	decor_box(car, "Car_Grille", Vector3(2.010, 0.390, 0.0), Vector3(0.04, 0.08, 0.66), car_trim)
	decor_box(car, "Car_Diffuser", Vector3(-1.94, 0.280, 0.0), Vector3(0.26, 0.05, 0.96), car_trim)
	decor_box(car, "Car_RearWing", Vector3(-1.66, 0.790, 0.0), Vector3(0.34, 0.05, 1.02), car_body)
	decor_box(car, "Car_WingPostL", Vector3(-1.72, 0.755, 0.40), Vector3(0.10, 0.09, 0.06), car_trim)
	decor_box(car, "Car_WingPostR", Vector3(-1.72, 0.755, -0.40), Vector3(0.10, 0.09, 0.06), car_trim)

	decor_box(car, "Car_SeatL", Vector3(-0.30, 0.62, 0.30), Vector3(0.40, 0.15, 0.34), car_seat)
	decor_box(car, "Car_SeatR", Vector3(-0.30, 0.62, -0.30), Vector3(0.40, 0.15, 0.34), car_seat)
	decor_box(car, "Car_Dash", Vector3(0.22, 0.68, 0.0), Vector3(0.20, 0.09, 0.98), car_trim)
	decor_box(car, "Car_Wheel_L", Vector3(0.32, 0.72, 0.26), Vector3(0.04, 0.16, 0.04), metal)

	decor_box(car, "Car_DayBar", Vector3(2.045, 0.500, 0.0), Vector3(0.04, 0.022, 0.58), headlight)
	decor_box(car, "Car_HeadlightL", Vector3(2.045, 0.470, 0.40), Vector3(0.05, 0.050, 0.20), headlight)
	decor_box(car, "Car_HeadlightR", Vector3(2.045, 0.470, -0.40), Vector3(0.05, 0.050, 0.20), headlight)
	decor_box(car, "Car_TaillightL", Vector3(-2.060, 0.610, 0.44), Vector3(0.04, 0.065, 0.32), taillight)
	decor_box(car, "Car_TaillightR", Vector3(-2.060, 0.610, -0.44), Vector3(0.04, 0.065, 0.32), taillight)

	decor_box(car, "Car_MirrorStalkL", Vector3(0.38, 0.82, 0.84), Vector3(0.10, 0.04, 0.12), car_body)
	decor_box(car, "Car_MirrorStalkR", Vector3(0.38, 0.82, -0.84), Vector3(0.10, 0.04, 0.12), car_body)
	decor_box(car, "Car_MirrorL", Vector3(0.40, 0.86, 0.92), Vector3(0.08, 0.070, 0.13), car_body)
	decor_box(car, "Car_MirrorR", Vector3(0.40, 0.86, -0.92), Vector3(0.08, 0.070, 0.13), car_body)

	decor_box(car, "Car_SillL", Vector3(0.10, 0.40, 0.905), Vector3(1.96, 0.10, 0.05), car_trim)
	decor_box(car, "Car_SillR", Vector3(0.10, 0.40, -0.905), Vector3(1.96, 0.10, 0.05), car_trim)

	for side in [1.0, -1.0]:
		var beam := SpotLight3D.new()
		beam.name = "HeadBeam_%d" % int(side)
		beam.position = Vector3(1.97, 0.62, 0.52 * side)
		beam.rotation_degrees = Vector3(-7, -90, 0)
		beam.light_energy = 6.0
		beam.light_color = Color(1.0, 0.95, 0.85)
		beam.spot_range = 60.0
		beam.spot_angle = 26.0
		car.add_child(beam)

	var wheel_pos := [Vector3(1.28, 0.34, 0.80), Vector3(1.28, 0.34, -0.80), Vector3(-1.28, 0.34, 0.80), Vector3(-1.28, 0.34, -0.80)]
	var index := 0
	for wp in wheel_pos:
		var out_sign := 1.0 if wp.z > 0.0 else -1.0
		decor_cyl(car, "Wheel_%d" % index, wp, 0.34, 0.24, Vector3(90, 0, 0), rubber)
		decor_cyl(car, "WheelRim_%d" % index, wp + Vector3(0, 0, 0.09 * out_sign), 0.205, 0.10, Vector3(90, 0, 0), metal_light)
		decor_cyl(car, "WheelHub_%d" % index, wp + Vector3(0, 0, 0.145 * out_sign), 0.075, 0.05, Vector3(90, 0, 0), car_trim)

		var flare := mesh_sphere(1.0, 2.0, car_silver)
		flare.name = "FenderFlare_%d" % index
		flare.position = wp + Vector3(0, 0.10, 0.01 * out_sign)
		flare.scale = Vector3(0.46, 0.17, 0.33)
		car.add_child(flare)
		index += 1
	return car


func make_robot() -> Node3D:
	var robot := Node3D.new()
	robot.name = "Brokk_Wrecker"

	var chassis := Node3D.new()
	chassis.name = "Chassis"
	robot.add_child(chassis)

	for side in [-1.0, 1.0]:
		var tag := "L" if side < 0.0 else "R"
		decor_box(chassis, "Track_%s" % tag, Vector3(0.66 * side, 0.34, 0.0), Vector3(0.38, 0.54, 2.46), robot_black)
		decor_box(chassis, "TrackPad_%s" % tag, Vector3(0.66 * side, 0.10, 0.0), Vector3(0.42, 0.16, 2.30), rubber)
		decor_box(chassis, "TrackFrame_%s" % tag, Vector3(0.66 * side, 0.34, 0.0), Vector3(0.30, 0.30, 2.10), metal)
		for wheel in [-0.72, -0.24, 0.24, 0.72]:
			decor_cyl(chassis, "Roller_%s_%d" % [tag, int(wheel * 100.0)], Vector3(0.66 * side, 0.20, wheel), 0.19, 0.16, Vector3(0, 0, 90), metal_light)
		decor_cyl(chassis, "Sprocket_%s" % tag, Vector3(0.66 * side, 0.44, -0.92), 0.24, 0.14, Vector3(0, 0, 90), metal)
		decor_cyl(chassis, "Idler_%s" % tag, Vector3(0.66 * side, 0.44, 0.95), 0.22, 0.14, Vector3(0, 0, 90), metal)

	decor_box(chassis, "Deck", Vector3(0, 0.66, 0.0), Vector3(0.98, 0.30, 1.78), robot_yellow)
	decor_box(chassis, "DeckSkirt", Vector3(0, 0.52, 0.0), Vector3(1.16, 0.16, 1.64), robot_yellow)
	decor_box(chassis, "EngineHood", Vector3(0, 0.92, -0.46), Vector3(0.80, 0.32, 0.72), robot_black)
	decor_box(chassis, "HoodLid", Vector3(0, 1.09, -0.46), Vector3(0.70, 0.05, 0.62), metal)
	decor_box(chassis, "BrandPlate", Vector3(0.50, 0.70, -0.10), Vector3(0.03, 0.18, 0.86), metal_light)
	decor_box(chassis, "BrandCap", Vector3(0.52, 0.70, 0.22), Vector3(0.02, 0.10, 0.14), robot_beacon)
	decor_box(chassis, "Exhaust", Vector3(-0.36, 1.12, -0.62), Vector3(0.08, 0.36, 0.08), metal)
	decor_cyl(chassis, "ExhaustTip", Vector3(-0.36, 1.31, -0.62), 0.055, 0.10, Vector3.ZERO, robot_black)

	for corner in [[-1.0, -1.0], [1.0, -1.0], [-1.0, 1.0], [1.0, 1.0]]:
		var sx: float = corner[0]
		var sz: float = corner[1]
		var tag := "%s%s" % ["L" if sx < 0.0 else "R", "B" if sz < 0.0 else "F"]
		var pivot := Vector3(0.46 * sx, 0.52, 0.86 * sz)
		decor_box_rot(chassis, "Outrigger_%s" % tag, pivot + Vector3(0.30 * sx, 0.10 * sz, 0.34 * sz), Vector3(0.16, 0.16, 0.90), Vector3(0.0, 0.0, -22.0 * sx), robot_yellow)
		decor_box(chassis, "OutriggerFoot_%s" % tag, Vector3(0.86 * sx, 0.13, 1.16 * sz), Vector3(0.30, 0.16, 0.30), metal)
		decor_box(chassis, "OutriggerPost_%s" % tag, Vector3(0.86 * sx, 0.34, 1.16 * sz), Vector3(0.12, 0.34, 0.12), metal)

	var turret := Node3D.new()
	turret.name = "Turret"
	turret.position = Vector3(0, 1.02, 0.30)
	chassis.add_child(turret)
	decor_cyl(turret, "TurretRing", Vector3(0, -0.10, 0), 0.44, 0.16, Vector3.ZERO, metal)
	decor_box(turret, "TurretBody", Vector3(0, 0.16, -0.04), Vector3(0.84, 0.34, 0.92), robot_yellow)
	decor_box(turret, "TurretSeat", Vector3(0.30, 0.42, -0.22), Vector3(0.28, 0.20, 0.30), robot_black)
	decor_box(turret, "Beacon", Vector3(-0.34, 0.38, -0.30), Vector3(0.11, 0.12, 0.11), robot_beacon)

	var boom := Node3D.new()
	boom.name = "BoomPivot"
	boom.position = Vector3(0, 0.34, 0.24)
	turret.add_child(boom)

	decor_box_rot(boom, "LowerBoom", Vector3(0, 0.614, 0.43), Vector3(0.30, 0.34, 1.50), Vector3(-58, 0, 0), robot_yellow)
	decor_box_rot(boom, "LowerBoomRib", Vector3(0, 0.614, 0.43), Vector3(0.34, 0.10, 1.20), Vector3(-58, 0, 0), robot_black)
	decor_cyl(boom, "BoomHinge", Vector3(0, 0, 0), 0.18, 0.40, Vector3(0, 0, 90), metal)

	var mid := Vector3(0, 1.272, 0.795)
	decor_cyl(boom, "KneeJoint", mid, 0.17, 0.36, Vector3(0, 0, 90), metal)
	decor_box_rot(boom, "UpperBoom", mid + Vector3(0, 0.186, 0.571), Vector3(0.26, 0.28, 1.20), Vector3(-18, 0, 0), robot_yellow)
	decor_box_rot(boom, "UpperBoomRib", mid + Vector3(0, 0.186, 0.571), Vector3(0.30, 0.08, 0.96), Vector3(-18, 0, 0), robot_black)

	var tip := Vector3(0, 1.643, 1.936)
	decor_cyl(boom, "TipJoint", tip, 0.14, 0.30, Vector3(0, 0, 90), metal)
	decor_box_rot(boom, "ToolArm", tip + Vector3(0, -0.398, 0.212), Vector3(0.22, 0.24, 0.90), Vector3(62, 0, 0), robot_yellow)
	decor_box_rot(boom, "ToolArmRib", tip + Vector3(0, -0.398, 0.212), Vector3(0.26, 0.07, 0.72), Vector3(62, 0, 0), robot_black)

	var hammer := Node3D.new()
	hammer.name = "Hammer"
	hammer.position = Vector3(0, 0.848, 2.359)
	boom.add_child(hammer)
	decor_box(hammer, "HammerBody", Vector3(0, -0.20, 0), Vector3(0.28, 0.52, 0.26), robot_black)
	decor_box(hammer, "HammerRail", Vector3(0, -0.20, 0.14), Vector3(0.20, 0.40, 0.03), metal_light)
	decor_box(hammer, "HammerMount", Vector3(0, 0.10, 0), Vector3(0.34, 0.14, 0.30), robot_yellow)
	var chisel := decor_box(hammer, "Chisel", Vector3(0, -0.62, 0), Vector3(0.10, 0.42, 0.10), metal_light)
	chisel.name = "Chisel"
	decor_cyl(hammer, "ChiselTip", Vector3(0, -0.86, 0), 0.035, 0.12, Vector3.ZERO, metal_light)

	decor_cyl(boom, "Hose_Main", mid * 0.5 + Vector3(0.16, 0.10, 0), 0.035, 1.10, Vector3(-40, 0, 0), robot_hose)
	decor_cyl(boom, "Hose_Tool", tip + Vector3(-0.15, -0.20, 0.05), 0.032, 0.82, Vector3(64, 0, 0), robot_hose)
	decor_box(boom, "HoseClamp_A", Vector3(0.14, 0.70, 0.55), Vector3(0.06, 0.10, 0.10), robot_black)
	decor_box(boom, "HoseClamp_B", Vector3(0.14, 1.42, 1.45), Vector3(0.06, 0.10, 0.10), robot_black)

	var work := OmniLight3D.new()
	work.name = "WorkLight"
	work.position = Vector3(0, 0.42, 0.62)
	work.light_energy = 1.4
	work.light_color = Color(1.0, 0.82, 0.55)
	work.omni_range = 7.5
	turret.add_child(work)

	var beacon_glow := OmniLight3D.new()
	beacon_glow.name = "BeaconGlow"
	beacon_glow.position = Vector3(-0.34, 0.46, -0.30)
	beacon_glow.light_energy = 1.1
	beacon_glow.light_color = Color(1.0, 0.55, 0.12)
	beacon_glow.omni_range = 6.0
	turret.add_child(beacon_glow)

	return robot


func _sphere_at(pos: Vector3, radius: float, material: Material) -> MeshInstance3D:
	var mi := mesh_sphere(radius, radius * 2.0, material)
	mi.position = pos
	return mi


func make_hero() -> Node3D:
	var hero := Node3D.new()
	hero.name = "Hero_Spooner"

	decor_box(hero, "SoleL", Vector3(-0.13, 0.025, 0.05), Vector3(0.19, 0.05, 0.35), hero_boot)
	decor_box(hero, "SoleR", Vector3(0.13, 0.025, 0.05), Vector3(0.19, 0.05, 0.35), hero_boot)
	decor_box(hero, "BootL", Vector3(-0.13, 0.11, 0.04), Vector3(0.17, 0.14, 0.30), hero_boot)
	decor_box(hero, "BootR", Vector3(0.13, 0.11, 0.04), Vector3(0.17, 0.14, 0.30), hero_boot)
	decor_box(hero, "ShinL", Vector3(-0.13, 0.42, 0), Vector3(0.16, 0.50, 0.18), hero_denim)
	decor_box(hero, "ShinR", Vector3(0.13, 0.42, 0), Vector3(0.16, 0.50, 0.18), hero_denim)
	decor_box(hero, "KneeL", Vector3(-0.13, 0.72, 0.01), Vector3(0.175, 0.10, 0.19), hero_denim)
	decor_box(hero, "KneeR", Vector3(0.13, 0.72, 0.01), Vector3(0.175, 0.10, 0.19), hero_denim)
	decor_box(hero, "ThighL", Vector3(-0.13, 0.95, 0), Vector3(0.19, 0.40, 0.21), hero_denim)
	decor_box(hero, "ThighR", Vector3(0.13, 0.95, 0), Vector3(0.19, 0.40, 0.21), hero_denim)
	decor_box(hero, "ThighFlareL", Vector3(-0.13, 0.79, 0), Vector3(0.205, 0.14, 0.22), hero_denim)
	decor_box(hero, "ThighFlareR", Vector3(0.13, 0.79, 0), Vector3(0.205, 0.14, 0.22), hero_denim)
	decor_box(hero, "Hips", Vector3(0, 1.20, 0), Vector3(0.34, 0.22, 0.23), hero_denim)
	decor_box(hero, "Belt", Vector3(0, 1.30, 0), Vector3(0.36, 0.07, 0.25), hero_boot)

	decor_box(hero, "Shirt", Vector3(0, 1.46, 0.02), Vector3(0.30, 0.34, 0.20), hero_shirt)
	decor_box(hero, "CoatBack", Vector3(0, 1.06, -0.135), Vector3(0.44, 0.88, 0.08), hero_leather)
	decor_box(hero, "CoatYoke", Vector3(0, 1.475, -0.155), Vector3(0.40, 0.13, 0.06), hero_leather)
	decor_box_rot(hero, "CoatSeamL", Vector3(-0.11, 1.10, -0.178), Vector3(0.012, 0.84, 0.012), Vector3(0, 0, 0), hero_boot)
	decor_box_rot(hero, "CoatSeamR", Vector3(0.11, 1.10, -0.178), Vector3(0.012, 0.84, 0.012), Vector3(0, 0, 0), hero_boot)
	decor_box(hero, "CoatSideL", Vector3(-0.210, 1.04, -0.01), Vector3(0.07, 0.86, 0.27), hero_leather)
	decor_box(hero, "CoatSideR", Vector3(0.210, 1.04, -0.01), Vector3(0.07, 0.86, 0.27), hero_leather)
	decor_box(hero, "CoatPanelL", Vector3(-0.115, 1.06, 0.130), Vector3(0.20, 0.88, 0.08), hero_leather)
	decor_box(hero, "CoatPanelR", Vector3(0.115, 1.06, 0.130), Vector3(0.20, 0.88, 0.08), hero_leather)
	decor_box(hero, "CoatFlareL", Vector3(-0.252, 0.70, -0.02), Vector3(0.06, 0.16, 0.29), hero_leather)
	decor_box(hero, "CoatFlareR", Vector3(0.252, 0.70, -0.02), Vector3(0.06, 0.16, 0.29), hero_leather)
	decor_box(hero, "CoatHem", Vector3(0, 0.640, -0.02), Vector3(0.52, 0.055, 0.33), hero_leather)
	decor_box(hero, "CoatChest", Vector3(0, 1.44, 0), Vector3(0.44, 0.38, 0.29), hero_leather)
	decor_box(hero, "CoatBelt", Vector3(0, 1.28, 0.02), Vector3(0.44, 0.07, 0.30), hero_boot)
	decor_box(hero, "Buckle", Vector3(0, 1.28, 0.175), Vector3(0.07, 0.06, 0.03), hero_buckle)
	decor_box(hero, "CoatZip", Vector3(0, 1.44, 0.152), Vector3(0.016, 0.30, 0.01), metal)

	decor_box_rot(hero, "LapelL", Vector3(-0.10, 1.56, 0.14), Vector3(0.12, 0.20, 0.03), Vector3(0, 0, 14), hero_leather)
	decor_box_rot(hero, "LapelR", Vector3(0.10, 1.56, 0.14), Vector3(0.12, 0.20, 0.03), Vector3(0, 0, -14), hero_leather)
	decor_box(hero, "CollarBack", Vector3(0, 1.63, -0.09), Vector3(0.26, 0.10, 0.08), hero_leather)
	decor_box(hero, "CollarL", Vector3(-0.11, 1.615, 0.02), Vector3(0.05, 0.11, 0.20), hero_leather)
	decor_box(hero, "CollarR", Vector3(0.11, 1.615, 0.02), Vector3(0.05, 0.11, 0.20), hero_leather)

	decor_box_rot(hero, "ShoulderSlopeL", Vector3(-0.178, 1.598, -0.005), Vector3(0.15, 0.075, 0.25), Vector3(0, 0, 21), hero_leather)
	decor_box_rot(hero, "ShoulderSlopeR", Vector3(0.178, 1.598, -0.005), Vector3(0.15, 0.075, 0.25), Vector3(0, 0, -21), hero_leather)
	decor_box(hero, "ShoulderL", Vector3(-0.252, 1.545, 0), Vector3(0.125, 0.14, 0.25), hero_leather)
	decor_box(hero, "ShoulderR", Vector3(0.252, 1.545, 0), Vector3(0.125, 0.14, 0.25), hero_leather)
	decor_box(hero, "UpperArmL", Vector3(-0.290, 1.360, 0.01), Vector3(0.140, 0.42, 0.175), hero_boot)
	decor_box(hero, "UpperArmR", Vector3(0.290, 1.360, 0.01), Vector3(0.140, 0.42, 0.175), hero_boot)
	decor_box(hero, "ElbowL", Vector3(-0.296, 1.150, 0.02), Vector3(0.145, 0.07, 0.18), hero_leather)
	decor_box(hero, "ElbowR", Vector3(0.296, 1.150, 0.02), Vector3(0.145, 0.07, 0.18), hero_leather)
	decor_box(hero, "ForearmL", Vector3(-0.302, 0.960, 0.04), Vector3(0.132, 0.34, 0.16), hero_boot)
	decor_box(hero, "ForearmR", Vector3(0.302, 0.960, 0.04), Vector3(0.132, 0.34, 0.16), hero_boot)
	decor_box(hero, "CuffL", Vector3(-0.302, 0.820, 0.04), Vector3(0.148, 0.07, 0.175), hero_leather)
	decor_box(hero, "CuffR", Vector3(0.302, 0.820, 0.04), Vector3(0.148, 0.07, 0.175), hero_leather)
	decor_box(hero, "HandL", Vector3(-0.302, 0.730, 0.05), Vector3(0.10, 0.14, 0.12), hero_skin)
	decor_box(hero, "HandR", Vector3(0.302, 0.730, 0.05), Vector3(0.10, 0.14, 0.12), hero_skin)

	decor_box(hero, "Neck", Vector3(0, 1.665, 0), Vector3(0.115, 0.10, 0.115), hero_skin)
	var head := _sphere_at(Vector3(0, 1.80, 0), 0.11, hero_skin)
	head.name = "Head"
	head.scale = Vector3(0.95, 1.15, 1.0)
	hero.add_child(head)
	decor_box(hero, "Jaw", Vector3(0, 1.725, 0.025), Vector3(0.155, 0.09, 0.155), hero_skin)
	decor_box(hero, "CheekL", Vector3(-0.062, 1.80, 0.048), Vector3(0.05, 0.06, 0.04), hero_skin)
	decor_box(hero, "CheekR", Vector3(0.062, 1.80, 0.048), Vector3(0.05, 0.06, 0.04), hero_skin)
	decor_box(hero, "EarL", Vector3(-0.107, 1.815, 0.0), Vector3(0.025, 0.065, 0.045), hero_skin)
	decor_box(hero, "EarR", Vector3(0.107, 1.815, 0.0), Vector3(0.025, 0.065, 0.045), hero_skin)
	decor_box(hero, "Nose", Vector3(0, 1.788, 0.092), Vector3(0.036, 0.070, 0.040), hero_skin)
	decor_box(hero, "NoseTip", Vector3(0, 1.772, 0.108), Vector3(0.032, 0.026, 0.026), hero_skin)
	decor_box(hero, "EyeL", Vector3(-0.045, 1.827, 0.089), Vector3(0.034, 0.020, 0.012), hero_eye)
	decor_box(hero, "EyeR", Vector3(0.045, 1.827, 0.089), Vector3(0.034, 0.020, 0.012), hero_eye)
	decor_box(hero, "IrisL", Vector3(-0.045, 1.827, 0.095), Vector3(0.015, 0.016, 0.006), hero_iris)
	decor_box(hero, "IrisR", Vector3(0.045, 1.827, 0.095), Vector3(0.015, 0.016, 0.006), hero_iris)
	decor_box(hero, "PupilL", Vector3(-0.045, 1.827, 0.098), Vector3(0.007, 0.008, 0.004), hero_pupil)
	decor_box(hero, "PupilR", Vector3(0.045, 1.827, 0.098), Vector3(0.007, 0.008, 0.004), hero_pupil)
	decor_box_rot(hero, "BrowL", Vector3(-0.049, 1.852, 0.094), Vector3(0.055, 0.014, 0.02), Vector3(0, 0, -6), hero_hair)
	decor_box_rot(hero, "BrowR", Vector3(0.049, 1.852, 0.094), Vector3(0.055, 0.014, 0.02), Vector3(0, 0, 6), hero_hair)
	decor_box(hero, "Mouth", Vector3(0, 1.742, 0.098), Vector3(0.062, 0.012, 0.02), hero_pupil)
	decor_box(hero, "Moustache", Vector3(0, 1.756, 0.098), Vector3(0.072, 0.014, 0.02), hero_hair)
	decor_box(hero, "Goatee", Vector3(0, 1.708, 0.088), Vector3(0.072, 0.05, 0.045), hero_hair)
	decor_box(hero, "BeardLineL", Vector3(-0.062, 1.742, 0.072), Vector3(0.03, 0.05, 0.04), hero_hair)
	decor_box(hero, "BeardLineR", Vector3(0.062, 1.742, 0.072), Vector3(0.03, 0.05, 0.04), hero_hair)

	var beanie := _sphere_at(Vector3(0, 1.895, -0.004), 0.124, hero_hair)
	beanie.name = "Beanie"
	beanie.scale = Vector3(1.02, 0.74, 1.02)
	hero.add_child(beanie)
	decor_box(hero, "BeanieRim", Vector3(0, 1.884, -0.002), Vector3(0.243, 0.05, 0.243), hero_hair)
	decor_box(hero, "BeanieKnot", Vector3(0, 1.962, -0.01), Vector3(0.05, 0.03, 0.05), hero_hair)
	decor_box(hero, "SideburnL", Vector3(-0.100, 1.856, 0.030), Vector3(0.022, 0.085, 0.060), hero_hair)
	decor_box(hero, "SideburnR", Vector3(0.100, 1.856, 0.030), Vector3(0.022, 0.085, 0.060), hero_hair)

	decor_box(hero, "Badge", Vector3(0.165, 1.435, 0.152), Vector3(0.075, 0.095, 0.018), hero_buckle)
	decor_box(hero, "BadgeStar", Vector3(0.165, 1.435, 0.164), Vector3(0.040, 0.048, 0.010), hero_skin)
	decor_box(hero, "PocketL", Vector3(-0.145, 1.145, 0.140), Vector3(0.165, 0.135, 0.020), hero_leather)
	decor_box(hero, "PocketR", Vector3(0.145, 1.145, 0.140), Vector3(0.165, 0.135, 0.020), hero_leather)
	decor_box(hero, "PocketFlapL", Vector3(-0.145, 1.208, 0.150), Vector3(0.170, 0.038, 0.022), hero_leather)
	decor_box(hero, "PocketFlapR", Vector3(0.145, 1.208, 0.150), Vector3(0.170, 0.038, 0.022), hero_leather)
	decor_box(hero, "ZipPull", Vector3(0, 1.615, 0.158), Vector3(0.022, 0.038, 0.012), hero_buckle)
	decor_box(hero, "Watch", Vector3(-0.288, 0.872, 0.040), Vector3(0.088, 0.040, 0.112), hero_buckle)
	decor_box(hero, "WatchFace", Vector3(-0.334, 0.872, 0.040), Vector3(0.012, 0.032, 0.070), metal_light)

	decor_box(hero, "Holster", Vector3(0.243, 1.055, -0.030), Vector3(0.080, 0.235, 0.140), hero_boot)
	decor_box(hero, "HolsterGrip", Vector3(0.252, 1.205, 0.040), Vector3(0.060, 0.100, 0.075), metal)
	decor_box(hero, "HolsterStrap", Vector3(0.250, 1.095, -0.100), Vector3(0.030, 0.180, 0.030), hero_buckle)

	decor_box(hero, "BootTreadL", Vector3(-0.13, 0.004, 0.05), Vector3(0.20, 0.014, 0.37), hero_buckle)
	decor_box(hero, "BootTreadR", Vector3(0.13, 0.004, 0.05), Vector3(0.20, 0.014, 0.37), hero_buckle)
	for i in range(3):
		decor_box(hero, "LaceL_%d" % i, Vector3(-0.13, 0.085 + i * 0.045, 0.155), Vector3(0.130, 0.014, 0.020), hero_buckle)
		decor_box(hero, "LaceR_%d" % i, Vector3(0.13, 0.085 + i * 0.045, 0.155), Vector3(0.130, 0.014, 0.020), hero_buckle)
	decor_box(hero, "HemL", Vector3(-0.13, 0.215, 0), Vector3(0.198, 0.045, 0.215), hero_denim)
	decor_box(hero, "HemR", Vector3(0.13, 0.215, 0), Vector3(0.198, 0.045, 0.215), hero_denim)
	decor_box(hero, "FingerL", Vector3(-0.31, 0.665, 0.045), Vector3(0.095, 0.065, 0.115), hero_skin)
	decor_box(hero, "FingerR", Vector3(0.31, 0.665, 0.045), Vector3(0.095, 0.065, 0.115), hero_skin)

	var torch := SpotLight3D.new()
	torch.name = "HeroTorch"
	torch.position = Vector3(0.3, 0.8, 0.08)
	torch.rotation_degrees = Vector3(-4, 0, 0)
	torch.light_energy = 2.1
	torch.light_color = Color(1.0, 0.94, 0.84)
	torch.spot_range = 22.0
	torch.spot_angle = 24.0
	torch.shadow_enabled = false
	hero.add_child(torch)
	return hero


func make_cat() -> Node3D:
	var cat := Node3D.new()
	cat.name = "Cat"

	var body := SphereMesh.new()
	body.radius = 0.16
	body.height = 0.4
	var body_mi := MeshInstance3D.new()
	body_mi.name = "CatBody"
	body_mi.mesh = body
	body_mi.material_override = cat_fur
	body_mi.position = Vector3(0, 0.2, 0)
	body_mi.scale = Vector3(1.0, 0.85, 1.5)
	cat.add_child(body_mi)

	var head := SphereMesh.new()
	head.radius = 0.11
	head.height = 0.22
	var head_mi := MeshInstance3D.new()
	head_mi.name = "CatHead"
	head_mi.mesh = head
	head_mi.material_override = cat_fur
	head_mi.position = Vector3(0, 0.32, 0.22)
	cat.add_child(head_mi)

	decor_box(cat, "CatEarL", Vector3(-0.06, 0.42, 0.22), Vector3(0.04, 0.08, 0.04), cat_fur)
	decor_box(cat, "CatEarR", Vector3(0.06, 0.42, 0.22), Vector3(0.04, 0.08, 0.04), cat_fur)
	decor_box(cat, "CatTail", Vector3(0, 0.3, -0.24), Vector3(0.05, 0.05, 0.26), cat_dark)
	return cat
