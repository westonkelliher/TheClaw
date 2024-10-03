extends RigidBody3D


@export var SPEED := 1.0
@export var ACC := 0.5
@export var TURN_SPEED := 0.5

var target := Vector3.ZERO
var angle_offset := 0.0

var gravity := 9.8

func _physics_process(delta: float) -> void:
	turn_toward_target(delta)
	walk_forward(delta)
	#rotation.z = move_toward(rotation.z, 0.0, pow(abs(rotation.z),2.0)*50.0*delta)
	#rotation.x = move_toward(rotation.x, 0.0, pow(abs(rotation.x),2.0)*50.0*delta)
	if abs(angular_velocity.y) < 2.0:
		apply_torque(Vector3(0.0, 1.0, 0.0)*0.01)
	if has_fallen():
		standup()

func walk_forward(delta: float) -> void:
	var forward := (basis * Vector3.FORWARD).normalized()
	var fric_force := mass*physics_material_override.friction*gravity
	apply_force(forward*fric_force, $FootSpot.position)
	if linear_velocity.dot(forward) < SPEED:
		# take off 1*ACC in current direction and add 2*ACC forward
		apply_force(-linear_velocity.normalized()*ACC)
		apply_force(2*forward*ACC)

func turn_toward_target(delta: float) -> void:
	var forward := (basis * Vector3.FORWARD).normalized()
	var target_forward := (target - global_position).normalized()
	var angle_to_target := forward.angle_to(target_forward)
	apply_torque(Vector3(0.0, angle_to_target, 0.0)*0.5)
	

func has_fallen() -> bool:
	return false

func standup() -> void:
	pass

func is_standing() -> bool:
	return abs($FootSpot.y) < 0.02
