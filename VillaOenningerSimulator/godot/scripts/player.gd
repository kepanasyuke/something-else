extends CharacterBody3D

const WALK_SPEED := 4.6
const RUN_SPEED := 8.2
const JUMP_VELOCITY := 4.8
const GRAVITY := 18.0
const MOUSE_SENSITIVITY := 0.0022
const EYE_HEIGHT := 1.68

var control_enabled := false
var camera: Camera3D
var carry: Node3D

var _pitch := 0.0
var _shake := 0.0
var _gravity := GRAVITY


func _ready() -> void:
	camera = get_node_or_null("Camera3D")
	if ProjectSettings.has_setting("physics/3d/default_gravity"):
		_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity"))


func _unhandled_input(event: InputEvent) -> void:
	if not control_enabled:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		_pitch = clampf(_pitch - event.relative.y * MOUSE_SENSITIVITY, -1.35, 1.35)
		if camera != null:
			camera.rotation.x = _pitch


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var direction := Vector3.ZERO
	if control_enabled:
		var input := Vector2.ZERO
		if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
			input.y -= 1.0
		if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
			input.y += 1.0
		if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
			input.x -= 1.0
		if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
			input.x += 1.0
		if input.length() > 1.0:
			input = input.normalized()
		direction = (transform.basis * Vector3(input.x, 0.0, input.y))
		direction.y = 0.0

		if is_on_floor() and Input.is_physical_key_pressed(KEY_SPACE):
			velocity.y = JUMP_VELOCITY

	var speed := RUN_SPEED if (Input.is_physical_key_pressed(KEY_SHIFT) or Input.is_physical_key_pressed(KEY_CTRL)) else WALK_SPEED
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()

	_update_shake(delta)


func _update_shake(delta: float) -> void:
	if camera == null:
		return
	var offset := Vector3.ZERO
	if _shake > 0.001:
		_shake = maxf(0.0, _shake - delta * 0.55)
		offset = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake
	camera.position = Vector3(0.0, EYE_HEIGHT, 0.0) + offset


func add_shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func set_control(enabled: bool) -> void:
	control_enabled = enabled
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if enabled else Input.MOUSE_MODE_VISIBLE


func pick_up(node: Node3D) -> void:
	carry = node
	if camera == null:
		return
	node.reparent(camera, false)
	node.position = Vector3(0.0, -0.35, -1.1)
	node.rotation = Vector3.ZERO
