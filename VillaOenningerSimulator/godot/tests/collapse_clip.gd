extends SceneTree

const STRIDE := 3
const START := 24
const END := 540

var game
var cam: Camera3D
var frames := 0
var out_dir := ""
var count := 0


func _initialize() -> void:
	out_dir = ProjectSettings.globalize_path("res://build/clip")
	DirAccess.make_dir_recursive_absolute(out_dir)
	for f in DirAccess.get_files_at(out_dir):
		if f.begins_with("frame_") and f.ends_with(".png"):
			DirAccess.remove_absolute(out_dir + "/" + f)

	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)

	cam = Camera3D.new()
	cam.fov = 58.0
	cam.near = 0.05
	cam.far = 900.0
	root.add_child(cam)
	cam.make_current()
	_view(Vector3(-34, 14, -30), Vector3(0, 3.5, 0))


func _view(pos: Vector3, target: Vector3) -> void:
	cam.look_at_from_position(pos, target, Vector3.UP)


func _process(_delta: float) -> bool:
	frames += 1

	if game.hud != null and game.hud.intro_root != null:
		game.hud.intro_root.hide()

	if frames == START:
		if game.hero != null:
			game.hero.visible = false
		game.director.start_delay = 1.6
		game.director.wave_step = 0.018
		game.director.start_collapse()
		game.robot.activate(Vector3(7.0, 0.0, 13.5))

	if frames >= START and frames <= END:
		var t := float(frames - START) / float(END - START)
		_view(Vector3(-34, 14, -30).lerp(Vector3(-25, 8, -21), t), Vector3(0, 3.5, 0))

		if (frames - START) % STRIDE == 0:
			var img := root.get_viewport().get_texture().get_image()
			img.save_png(out_dir + "/frame_%04d.png" % count)
			count += 1

	if frames > END + 8:
		print("CLIP=", count)
		quit(0)
		return true

	return false
