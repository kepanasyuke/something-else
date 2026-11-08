extends RigidBody3D

const DUST_COLOR := Color(0.78, 0.76, 0.72)

var is_collapsing := false


func _ready() -> void:
	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	contact_monitor = false


func collapse(origin: Vector3, power := 1.0) -> void:
	if is_collapsing:
		return
	is_collapsing = true
	freeze = false

	var direction: Vector3 = global_position - origin
	if direction.length() < 0.2:
		direction = Vector3(randf_range(-1.0, 1.0), 1.0, randf_range(-1.0, 1.0))
	direction.y *= 0.30
	direction = direction.normalized()
	direction += Vector3(randf_range(-0.28, 0.28), 0.0, randf_range(-0.28, 0.28))

	apply_central_impulse(direction * mass * 3.6 * power + Vector3(0.0, mass * 0.9 * power, 0.0))
	apply_torque_impulse(Vector3(randf_range(-1.0, 1.0), randf_range(-0.5, 0.5), randf_range(-1.0, 1.0)) * mass * 1.5)


func _physics_process(_delta: float) -> void:
	if global_position.y < -70.0:
		queue_free()
