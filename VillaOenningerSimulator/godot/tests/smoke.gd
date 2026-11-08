extends SceneTree

var game
var frames := 0
var started := false


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null:
		push_error("main.tscn не загрузился")
		quit(1)
		return
	game = packed.instantiate()
	root.add_child(game)


func _process(_delta: float) -> bool:
	frames += 1

	if frames == 2:
		print("PARTS=", game.director.total_parts())
		print("PLAYER=", game.player != null, " HUD=", game.hud != null)
		print("CAR=", game.car != null, " ROBOT=", game.robot != null, " CAT=", game.cat != null)
		game.director.start_delay = 0.2
		game.director.wave_step = 0.01
		game.director.start_collapse()
		game.robot.activate(Vector3(0.0, 0.0, 12.0))
		game.cat.rescue()
		started = true

	if frames == 60:
		print("SPAWN_Y=", snappedf(game.player.global_position.y, 0.01), " on_floor=", game.player.is_on_floor())

	if frames == 90:
		game.player.global_position = Vector3(8.4, 2.6, 3.3)

	if frames == 240:
		print("RAMP_Y=", snappedf(game.player.global_position.y, 0.01), " on_floor=", game.player.is_on_floor())
		game.player.global_position = Vector3(0.0, 1.5, 0.0)

	if started and frames == 300:
		print("ACTIVE=", game.director.active_parts(), "/", game.director.total_parts())
		print("ROBOT_POS=", game.robot.global_position)
		print("CAT_RESCUED=", game.cat_rescued)

	if frames >= 900:
		print("DONE frames=", frames, " active=", game.director.active_parts(), "/", game.director.total_parts())
		quit(0)
		return true
	return false
