extends Node3D

const SPEED := 2.1
const APPROACH := 2.4
const HAMMER_REACH := 4.6
const STRIKE_CYCLE := 1.05
const STRIKE_HIT := 0.34

var director
var active := false
var target := Vector3(0, 0, 0)

var _cycle := 0.0
var _struck := false
var _roll := 0.0
var _beam := 0.0

var _chassis: Node3D
var _boom: Node3D
var _chisel: Node3D
var _beacon: Node3D


func _ready() -> void:
	target = Vector3(4.0, 0.0, 14.0)
	_chassis = get_node_or_null("Chassis")
	_boom = get_node_or_null("Chassis/Turret/BoomPivot")
	_chisel = get_node_or_null("Chassis/Turret/BoomPivot/Hammer/Chisel")
	_beacon = get_node_or_null("Chassis/Turret/Beacon")


func activate(to: Vector3) -> void:
	target = to
	active = true


func _process(delta: float) -> void:
	_beam += delta
	if _beacon != null:
		_beacon.visible = fmod(_beam, 0.9) < 0.45

	_idle_boom(delta)

	if not active:
		return

	var to_target := target - global_position
	to_target.y = 0.0

	if to_target.length() > APPROACH:
		var step := to_target.normalized() * SPEED * delta
		global_position += step
		var want := atan2(to_target.x, to_target.z)
		rotation.y = lerp_angle(rotation.y, want, clampf(delta * 2.2, 0.0, 1.0))
		_roll += delta * 6.0
		if _chassis != null:
			_chassis.position.y = absf(sin(_roll)) * 0.02
		_cycle = 0.0
		_struck = false
		return

	strike(delta)


func strike(delta: float) -> void:
	_cycle += delta
	if _cycle >= STRIKE_CYCLE:
		_cycle = 0.0
		_struck = false

	var p := _cycle / STRIKE_CYCLE
	if p < STRIKE_HIT:
		var swing := p / STRIKE_HIT
		if _boom != null:
			_boom.rotation_degrees.x = -6.0 + swing * 16.0
		if _chisel != null:
			_chisel.position.y = -0.62 + swing * 0.14
	elif not _struck:
		_struck = true
		_wreck_nearby()
		if _boom != null:
			_boom.rotation_degrees.x = 10.0
		if _chisel != null:
			_chisel.position.y = -0.72
	else:
		var back := (p - STRIKE_HIT) / (1.0 - STRIKE_HIT)
		if _boom != null:
			_boom.rotation_degrees.x = lerpf(10.0, -6.0, back)
		if _chisel != null:
			_chisel.position.y = lerpf(-0.72, -0.62, back)


func _idle_boom(delta: float) -> void:
	if _boom == null or active:
		return
	_beam += delta * 0.6
	_boom.rotation_degrees.x = sin(_beam) * 1.6


func _wreck_nearby() -> void:
	if director == null:
		return
	var origin := global_position + Vector3(0, 1.4, 0)
	var hit := 0
	for part in director.parts:
		if not is_instance_valid(part):
			continue
		if part.is_collapsing:
			continue
		if part.global_position.distance_to(global_position) <= HAMMER_REACH:
			part.collapse(origin, 0.95)
			hit += 1
			if hit >= 3:
				break
	if hit > 0:
		director.progress_changed.emit(float(director.active_parts()) / maxf(1.0, float(director.total_parts())) * 100.0)
		director.shake_requested.emit(0.3)
