extends SceneTree

var game
var cam: Camera3D
var frames := 0
var out_dir := ""


func _initialize() -> void:
	out_dir = ProjectSettings.globalize_path("res://build/shots")
	DirAccess.make_dir_recursive_absolute(out_dir)

	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)

	cam = Camera3D.new()
	cam.fov = 70.0
	cam.near = 0.05
	cam.far = 900.0
	root.add_child(cam)
	cam.make_current()


func _view(pos: Vector3, target: Vector3) -> void:
	cam.look_at_from_position(pos, target, Vector3.UP)


func _shot(file_name: String) -> void:
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(out_dir + "/" + file_name + ".png")
	print("SHOT ", file_name)


func _process(_delta: float) -> bool:
	frames += 1

	if frames == 3:
		if game.hud != null and game.hud.intro_root != null:
			game.hud.intro_root.hide()
		_view(Vector3(-24, 7, -24), Vector3(0, 4, 0))

	if frames == 10:
		_shot("01-approach")

	if frames == 12:
		_view(Vector3(0, 3.2, 30), Vector3(0, 2.5, 8))

	if frames == 19:
		_shot("02-terrace")

	if frames == 20:
		_view(Vector3(2.0, 2.4, 15.4), Vector3(-7.0, 0.0, 14.0))

	if frames == 26:
		_shot("10-pool")

	if frames == 28:
		_view(Vector3(0.5, 1.85, -8.2), Vector3(1.5, 1.2, 4.0))

	if frames == 35:
		_shot("03-interior")

	if frames == 36:
		cam.fov = 50.0
		_view(Vector3(1.2, 2.6, -21.5), Vector3(7.9, 2.7, -14.8))

	if frames == 40:
		_shot("08-globe")
		cam.fov = 70.0

	if frames == 41:
		_view(Vector3(8.6, 2.0, 19.6), Vector3(11.5, 1.4, 15.5))

	if frames == 43:
		_shot("04-robot")

	if frames == 45:
		game.hero.visible = true
		game.hero.global_position = Vector3(-18.4, 0.05, -14.2)
		game.hero.look_at(Vector3(0.0, 1.0, 0.0), Vector3.UP)
		cam.fov = 45.0
		_view(Vector3(-16.0, 1.55, -12.0), Vector3(-18.4, 1.05, -14.2))

	if frames == 51:
		_shot("05-hero")
		cam.fov = 70.0

	if frames == 53:
		_view(Vector3(-26, 9, -22), Vector3(0, 5, 0))
		game.director.start_delay = 0.4
		game.director.wave_step = 0.12
		game.director.start_collapse()
		game.robot.activate(Vector3(2.0, 0.0, 12.0))

	if frames == 170:
		_shot("06-collapse")

	if frames == 340:
		_shot("07-aftermath")
		print("ACTIVE=", game.director.active_parts(), "/", game.director.total_parts())

	if frames == 358:
		_view(Vector3(-30, 16, -34), Vector3(0, 5, -2))
		cam.fov = 60.0

	if frames == 366:
		_shot("09-wide")

	if frames == 368:
		_view(Vector3(-2, 8, 44), Vector3(-2, 4, 2))
		cam.fov = 55.0

	if frames == 376:
		_shot("11-sea")

	if frames == 378:
		_view(Vector3(6, 40, 34), Vector3(-1, 2, 3))
		cam.fov = 58.0

	if frames == 386:
		_shot("12-aerial")
		quit(0)
		return true

	return false
