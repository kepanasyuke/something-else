extends SceneTree

var game
var cam: Camera3D
var frames := 0
var out_dir := ""

const ROBOT_POS := Vector3(11.5, 0.0, 15.5)
const HERO_POS := Vector3(-19.0, 0.05, -15.0)


func _initialize() -> void:
	out_dir = ProjectSettings.globalize_path("res://build/shots/closeups")
	DirAccess.make_dir_recursive_absolute(out_dir)

	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)

	cam = Camera3D.new()
	cam.fov = 38.0
	cam.near = 0.02
	cam.far = 200.0
	root.add_child(cam)
	cam.make_current()

	var key := SpotLight3D.new()
	key.name = "InspectKey"
	key.light_energy = 4.2
	key.light_color = Color(1.0, 0.96, 0.9)
	key.spot_range = 16.0
	key.spot_angle = 34.0
	key.shadow_enabled = false
	cam.add_child(key)

	var fill := OmniLight3D.new()
	fill.name = "InspectFill"
	fill.light_energy = 1.6
	fill.light_color = Color(0.55, 0.68, 0.95)
	fill.omni_range = 9.0
	cam.add_child(fill)


func _view(pos: Vector3, target: Vector3) -> void:
	cam.look_at_from_position(pos, target, Vector3.UP)


func _shot(file_name: String) -> void:
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(out_dir + "/" + file_name + ".png")
	print("SHOT ", file_name)


func _process(_delta: float) -> bool:
	frames += 1

	if frames == 4:
		if game.hud != null and game.hud.intro_root != null:
			game.hud.intro_root.hide()
		game.player.visible = false
		game.robot.global_position = ROBOT_POS
		game.robot.rotation.y = 0.0
		game.hero.visible = true
		game.hero.global_position = HERO_POS
		game.hero.rotation.y = 0.0

	if frames == 8:
		_view(ROBOT_POS + Vector3(0, 1.6, 5.2), ROBOT_POS + Vector3(0, 1.45, 0))

	if frames == 14:
		_shot("robot-front")

	if frames == 16:
		_view(ROBOT_POS + Vector3(5.2, 1.6, 0), ROBOT_POS + Vector3(0, 1.45, 0))

	if frames == 22:
		_shot("robot-profile")

	if frames == 24:
		_view(ROBOT_POS + Vector3(0, 1.6, -5.2), ROBOT_POS + Vector3(0, 1.45, 0))

	if frames == 30:
		_shot("robot-back")

	if frames == 32:
		cam.fov = 30.0
		_view(ROBOT_POS + Vector3(-1.7, 2.5, 4.6), ROBOT_POS + Vector3(0, 2.05, 2.4))

	if frames == 38:
		_shot("robot-hammer")
		cam.fov = 36.0

	if frames == 40:
		_view(HERO_POS + Vector3(0, 1.15, 3.1), HERO_POS + Vector3(0, 1.05, 0))

	if frames == 46:
		_shot("hero-front")

	if frames == 48:
		_view(HERO_POS + Vector3(3.1, 1.15, 0), HERO_POS + Vector3(0, 1.05, 0))

	if frames == 54:
		_shot("hero-profile")

	if frames == 56:
		_view(HERO_POS + Vector3(0, 1.15, -3.1), HERO_POS + Vector3(0, 1.05, 0))

	if frames == 62:
		_shot("hero-back")

	if frames == 64:
		cam.fov = 20.0
		_view(HERO_POS + Vector3(0.18, 1.83, 0.70), HERO_POS + Vector3(0, 1.82, 0))

	if frames == 70:
		_shot("hero-face")

	if frames == 72:
		cam.fov = 40.0
		game.car.global_position = Vector3(-19.0, 0.05, -15.0)
		game.car.rotation_degrees = Vector3(0, 35, 0)
		_view(Vector3(-12.0, 2.0, -9.6), Vector3(-19.0, 0.65, -15.0))

	if frames == 78:
		_shot("car-three-quarter")
		cam.fov = 38.0
		_view(Vector3(-12.4, 1.3, -19.6), Vector3(-19.0, 0.70, -15.0))

	if frames == 84:
		_shot("car-front")
		cam.fov = 38.0
		_view(Vector3(-25.5, 1.4, -10.5), Vector3(-19.0, 0.70, -15.0))

	if frames == 90:
		_shot("car-rear")
		print("CLOSEUPS=12")
		quit(0)
		return true

	return false
