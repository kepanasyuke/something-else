extends Node3D

const BUILDER_SCRIPT := preload("res://scripts/villa_builder.gd")
const DIRECTOR_SCRIPT := preload("res://scripts/collapse_director.gd")
const PLAYER_SCRIPT := preload("res://scripts/player.gd")
const CAR_SCRIPT := preload("res://scripts/car_arrival.gd")
const ROBOT_SCRIPT := preload("res://scripts/robot_wrecker.gd")
const CAT_SCRIPT := preload("res://scripts/cat_critter.gd")
const HUD_SCRIPT := preload("res://scripts/hud.gd")

const STATE_INTRO := 0
const STATE_WALK := 1
const STATE_ARRIVAL := 2
const STATE_COLLAPSE := 3

const CAT_POSITION := Vector3(4.5, 0.05, 16.5)
const RESCUE_RANGE := 3.2

var builder
var director
var player: CharacterBody3D
var hud
var car: Node3D
var robot: Node3D
var hero: Node3D
var cat: Node3D

var state := STATE_INTRO
var demolition_started := false
var cat_rescued := false
var _clock := 0.0


func _ready() -> void:
	_setup_environment()
	_setup_moon()
	_build_stars()
	_build_rain()

	director = DIRECTOR_SCRIPT.new()
	director.name = "CollapseDirector"
	add_child(director)
	director.shake_requested.connect(_on_shake)

	builder = BUILDER_SCRIPT.new()
	builder.director = director
	builder.build(self)

	_create_player()
	_create_car()
	_create_robot()
	_create_hero()
	_create_cat()

	hud = HUD_SCRIPT.new()
	hud.name = "HUD"
	add_child(hud)
	director.progress_changed.connect(hud.set_progress)
	hud.set_hint("WASD — идти, мышь — осмотреться, Shift — бег, Space — прыжок")
	director.progress_changed.emit(0.0)


func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY

	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.010, 0.016, 0.042)
	sky_material.sky_horizon_color = Color(0.048, 0.066, 0.104)
	sky_material.sky_curve = 0.14
	sky_material.ground_horizon_color = Color(0.032, 0.044, 0.064)
	sky_material.ground_bottom_color = Color(0.006, 0.009, 0.018)
	sky_material.sky_energy_multiplier = 0.5
	sky_material.ground_energy_multiplier = 0.35
	sky_material.sun_angle_max = 6.0
	sky_material.sun_curve = 0.05

	var sky := Sky.new()
	sky.sky_material = sky_material
	env.sky = sky

	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.26
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.98
	env.tonemap_white = 6.0

	var method := str(RenderingServer.get_current_rendering_method())
	var rich := method == "forward_plus" or method == "mobile"
	env.glow_enabled = rich
	env.glow_intensity = 0.55
	env.glow_bloom = 0.15
	env.fog_enabled = true
	env.fog_light_color = Color(0.055, 0.075, 0.115)
	env.fog_density = 0.006 if rich else 0.0035
	env.fog_sky_affect = 0.25

	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	world_env.environment = env
	add_child(world_env)


func _setup_moon() -> void:
	var moon := DirectionalLight3D.new()
	moon.name = "Moon"
	moon.rotation_degrees = Vector3(-38, 128, 0)
	moon.light_energy = 0.34
	moon.light_color = Color(0.62, 0.73, 1.0)
	moon.shadow_enabled = true
	moon.directional_shadow_max_distance = 240.0
	add_child(moon)

	var disc_mesh := SphereMesh.new()
	disc_mesh.radius = 7.0
	disc_mesh.height = 14.0
	disc_mesh.radial_segments = 24
	disc_mesh.rings = 12

	var disc_mat := StandardMaterial3D.new()
	disc_mat.albedo_color = Color(0.93, 0.95, 1.0)
	disc_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	disc_mat.emission_enabled = true
	disc_mat.emission = Color(0.82, 0.90, 1.0)
	disc_mat.emission_energy_multiplier = 1.3
	disc_mesh.material = disc_mat

	var disc := MeshInstance3D.new()
	disc.name = "MoonDisc"
	disc.mesh = disc_mesh
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	disc.position = Vector3(-210, 156, -340)
	add_child(disc)


func _build_stars() -> void:
	var star_mesh := SphereMesh.new()
	star_mesh.radius = 0.85
	star_mesh.height = 1.7
	star_mesh.radial_segments = 5
	star_mesh.rings = 3

	var star_mat := StandardMaterial3D.new()
	star_mat.albedo_color = Color(0.95, 0.97, 1.0)
	star_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	star_mat.emission_enabled = true
	star_mat.emission = Color(0.86, 0.92, 1.0)
	star_mat.emission_energy_multiplier = 1.6
	star_mat.disable_receive_shadows = true
	star_mesh.material = star_mat

	var rng := RandomNumberGenerator.new()
	rng.seed = 771077

	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = star_mesh
	multimesh.instance_count = 360

	for i in range(360):
		var dir := Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(0.06, 1.0), rng.randf_range(-1.0, 1.0)).normalized()
		var distance := rng.randf_range(330.0, 430.0)
		var size := rng.randf_range(0.6, 2.4)
		var basis := Basis().scaled(Vector3(size, size, size))
		multimesh.set_instance_transform(i, Transform3D(basis, dir * distance))

	var stars := MultiMeshInstance3D.new()
	stars.name = "Stars"
	stars.multimesh = multimesh
	stars.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(stars)


func _build_rain() -> void:
	_make_rain_emitter(Vector3(0, 22, -20), Vector3(42, 1.0, 11), 340)
	_make_rain_emitter(Vector3(0, 22, 23), Vector3(42, 1.0, 9), 340)
	_make_rain_emitter(Vector3(24, 22, 2), Vector3(11, 1.0, 13), 300)
	_make_rain_emitter(Vector3(-24, 22, 2), Vector3(11, 1.0, 13), 300)


func _make_rain_emitter(center: Vector3, extents: Vector3, amount: int) -> void:
	var rain := CPUParticles3D.new()
	rain.name = "Rain"
	rain.amount = amount
	rain.lifetime = 1.1
	rain.preprocess = 1.0
	rain.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	rain.emission_box_extents = extents
	rain.direction = Vector3(0.12, -1.0, 0.05)
	rain.spread = 4.0
	rain.initial_velocity_min = 26.0
	rain.initial_velocity_max = 34.0
	rain.gravity = Vector3(0, -9.8, 0)
	rain.scale_amount_min = 0.7
	rain.scale_amount_max = 1.5
	rain.color = Color(0.74, 0.84, 0.96, 0.30)

	var drop := QuadMesh.new()
	drop.size = Vector2(0.022, 0.44)

	var drop_mat := StandardMaterial3D.new()
	drop_mat.albedo_color = Color(0.74, 0.84, 0.96, 0.32)
	drop_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	drop_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	drop_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	drop_mat.disable_receive_shadows = true
	drop.material = drop_mat

	rain.mesh = drop
	rain.position = center
	add_child(rain)


func _create_player() -> void:
	player = PLAYER_SCRIPT.new()
	player.name = "Player"
	player.position = Vector3(-17, 0.4, -14)
	player.rotation.y = PI

	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.75
	collision.shape = capsule
	collision.position = Vector3(0, 0.9, 0)
	player.add_child(collision)

	var cam := Camera3D.new()
	cam.name = "Camera3D"
	cam.position = Vector3(0, 1.68, 0)
	cam.fov = 72.0
	cam.near = 0.05
	cam.far = 900.0
	player.add_child(cam)

	var torch := SpotLight3D.new()
	torch.name = "Torch"
	torch.position = Vector3(0.18, 1.55, -0.15)
	torch.rotation_degrees = Vector3(-6, 0, 0)
	torch.light_energy = 2.2
	torch.light_color = Color(1.0, 0.93, 0.82)
	torch.spot_range = 26.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = false
	cam.add_child(torch)

	add_child(player)
	player.set_control(false)


func _create_car() -> void:
	car = builder.make_car()
	car.set_script(CAR_SCRIPT)
	car.drive_from = Vector3(-46, 0.05, -26)
	car.drive_to = Vector3(-19, 0.05, -15)
	car.duration = 7.0
	add_child(car)
	car.arrived.connect(_on_car_arrived)


func _create_robot() -> void:
	robot = builder.make_robot()
	robot.set_script(ROBOT_SCRIPT)
	robot.director = director
	add_child(robot)
	robot.position = Vector3(11.5, 0, 15.5)


func _create_hero() -> void:
	hero = builder.make_hero()
	hero.name = "Hero"
	hero.position = Vector3(-19.0, 0.05, -15.0)
	hero.visible = false
	add_child(hero)


func _create_cat() -> void:
	cat = builder.make_cat()
	cat.set_script(CAT_SCRIPT)
	add_child(cat)
	cat.position = CAT_POSITION
	cat.rescued.connect(_on_cat_rescued)


func _input(event: InputEvent) -> void:
	if state == STATE_INTRO:
		var pressed := false
		if event is InputEventKey and event.pressed and not event.echo:
			pressed = true
		elif event is InputEventMouseButton and event.pressed:
			pressed = true
		if pressed:
			_leave_intro()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		_interact()


func _leave_intro() -> void:
	state = STATE_WALK
	hud.hide_intro()
	player.set_control(true)
	hud.set_hint("WASD — идти, мышь — осмотреться, Shift — бег, Space — прыжок, E — начать демонтаж")


func _interact() -> void:
	if not cat_rescued and player.global_position.distance_to(cat.global_position) <= RESCUE_RANGE:
		cat.rescue()
		return

	if not demolition_started:
		_start_demolition()


func _start_demolition() -> void:
	demolition_started = true
	state = STATE_ARRIVAL
	hud.toast("Вызов принят. Оператор уже в пути.", 4.0)
	hud.set_hint("Робот-разрушитель выходит на позицию…")
	car.begin()


func _on_car_arrived() -> void:
	var door := car.to_global(Vector3(1.7, 0.0, 1.1))
	hero.global_position = Vector3(door.x, 0.05, door.z)
	hero.visible = true
	hero.look_at(Vector3(0.0, 0.05, 0.0), Vector3.UP)

	hud.toast("Герой на месте. Робот-разрушитель запущен.", 4.0)
	state = STATE_COLLAPSE
	director.start_collapse()
	robot.activate(Vector3(2.0, 0.0, 12.0))
	player.add_shake(0.2)


func _on_shake(amount: float) -> void:
	if player != null:
		player.add_shake(amount)


func _on_cat_rescued() -> void:
	cat_rescued = true
	hud.toast("Кошка спасена. Первый закон выполнен.", 5.0)
	if player != null:
		player.pick_up(cat)


func _process(delta: float) -> void:
	_clock += delta
	if hero != null and hero.visible:
		hero.position.y = 0.05 + sin(_clock * 1.8) * 0.012

	if state == STATE_INTRO:
		return
	if player == null or cat == null:
		return

	if not cat_rescued:
		var near := player.global_position.distance_to(cat.global_position) <= RESCUE_RANGE
		if near and state != STATE_COLLAPSE:
			hud.set_hint("E — взять кошку на руки")
		elif demolition_started and state == STATE_ARRIVAL:
			hud.set_hint("Робот-разрушитель выходит на позицию…")
		elif not demolition_started:
			hud.set_hint("WASD — идти, мышь — осмотреться, Shift — бег, Space — прыжок, E — начать демонтаж")
