extends Node3D

signal arrived

var drive_from := Vector3(-46, 0.05, -26)
var drive_to := Vector3(-19, 0.05, -15)
var duration := 7.0
var driving := false

var _elapsed := 0.0
var _wheels: Array[Node3D] = []


func _ready() -> void:
	position = drive_from
	rotation.y = PI / 3.0
	for i in range(4):
		var wheel := get_node_or_null("Wheel%d" % i)
		if wheel != null:
			_wheels.append(wheel)


func begin() -> void:
	if driving:
		return
	driving = true
	_elapsed = 0.0


func _process(delta: float) -> void:
	if not driving:
		return

	_elapsed += delta
	var t := clampf(_elapsed / maxf(duration, 0.1), 0.0, 1.0)
	var eased := 1.0 - pow(1.0 - t, 2.4)
	position = drive_from.lerp(drive_to, eased)

	var heading := drive_to - drive_from
	if heading.length() > 0.1:
		rotation.y = atan2(heading.x, heading.z) + PI * 0.5

	for wheel in _wheels:
		wheel.rotation_degrees.z += 420.0 * delta

	if t >= 1.0:
		driving = false
		arrived.emit()
