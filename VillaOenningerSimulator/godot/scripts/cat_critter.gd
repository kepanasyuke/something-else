extends Node3D

signal rescued

var rescued_already := false
var home := Vector3.ZERO

var _time := 0.0
var _sound_offset := 0.0


func _ready() -> void:
	home = position
	_sound_offset = randf() * TAU


func rescue() -> void:
	if rescued_already:
		return
	rescued_already = true
	rescued.emit()


func _process(delta: float) -> void:
	_time += delta
	rotation.y = sin(_time * 0.8 + _sound_offset) * 0.5
	position.y = home.y + sin(_time * 1.6) * 0.02
