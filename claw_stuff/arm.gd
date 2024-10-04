@tool
extends Node3D
class_name Arm

class ArmPosition:
	var theta := 0.0
	var ro := 0.0


@export var MAX_ANGLE := 160.0
@export var LENGTH := 1.8 :
	set(value):
		LENGTH = value
		if !has_node("Arm/Shape"):
			return
		$Arm.position.y = LENGTH/2.0 - 0.1
		$Arm/Shape.shape = $Arm/Shape.shape.duplicate()
		$Arm/Shape.shape.height = LENGTH+0.2
		$Arm/Mesh.mesh = $Arm/Mesh.mesh.duplicate()
		$Arm/Mesh.mesh.height = LENGTH+0.2
		$Arm/End.position.y = LENGTH/2.0
		$Arm/Fins.scale.y = LENGTH
		$Arm/Fins2.scale.y = LENGTH
	get:
		return LENGTH


@export var MOTOR_DAMP_DISTANCE := 0.3 # measured in radians

@export var MAX_MOTOR1 := 1.0
@export var MAX_MOTOR2 := 2.0
@export var MOTOR_ACC1 := 5.0
@export var MOTOR_ACC2 := 1.5
var motor_velocity := Vector2(0.0, 0.0)
var motor_damp_start_speed := 0.0

@export var attached_to: NodePath = "":
	set(value):
		$ConeJoint.node_a = NodePath("../" + str(value))
		attached_to = value
	get:
		return attached_to


const REMEMBER_THRESHOLD := 0.1
var remembered_stick := Vector2.ONE

func _ready() -> void:
	if owner == null: # scene being tested standalone
		add_test_camera()
	pass
	#$Arm.linear_damp = 30.0

func _physics_process(delta: float) -> void:
	if owner == null: # scene being tested standalone
		test_input(delta)


## Testing ##
func add_test_camera() -> void:
	print("WARNING: Adding test camera to arm")
	var cam := Camera3D.new()
	cam.position = Vector3(0.0, 1.0, 3.0)
	get_parent().add_child.call_deferred(cam)

func test_input(delta: float) -> void:
	var gpi := InputHandler.get_gamepad_input()
	handle_input(gpi.stick_R, gpi.trig_R, delta)
## ------ ##

# Called every frame. 'delta' is the elapsed time since the previous frame.
func handle_input(stick: Vector2, trig: float, delta: float) -> void:
	if stick.length() > 0.95:
		stick = stick.normalized()*0.95
	stick /= 0.95
	if stick.length() > REMEMBER_THRESHOLD:
		var lerp_amnt := 1 - pow(0.00001, delta)
		remembered_stick = remembered_stick.lerp(stick.normalized(), lerp_amnt)
	var current := current_arm_position()
	var targ := target_arm_position(stick, trig)
	motor_towards_position(current, targ, delta)
	#return

#TODO: take the difference between current cylindrical coords and desired

func motor_towards_position(from: ArmPosition, to: ArmPosition, delta: float) -> void:
	var direction := arm_polar_direction(from, to)
	var dist := arm_distance(from, to)
	accelerate_motor(direction*dist, delta)
	apply_motor_velocity(delta)

# motor_vec represents the vector to the target position
func accelerate_motor(motor_vec: Vector2, delta: float) -> void:
	get_motor_velocity()
	if motor_vec.length() < MOTOR_DAMP_DISTANCE:
		decelerate_motor(motor_vec, delta)
		return
	motor_damp_start_speed = -1
	var motor_dot_speed := motor_velocity.dot(motor_vec.normalized())
	var acc := 0.0
	if motor_dot_speed < MAX_MOTOR1:
		motor_velocity -= motor_velocity.normalized()*MOTOR_ACC1*delta
		motor_velocity += 2*motor_vec.normalized()*MOTOR_ACC1*delta
	elif motor_dot_speed < MAX_MOTOR2:
		acc = MOTOR_ACC2
		motor_velocity -= motor_velocity.normalized()*MOTOR_ACC2*delta
		motor_velocity += 2*motor_vec.normalized()*MOTOR_ACC2*delta
	else:
		motor_velocity -= motor_velocity.normalized()*MOTOR_ACC1*delta
		motor_velocity += motor_vec.normalized()*MOTOR_ACC1*delta
	pass

func decelerate_motor(motor_vec: Vector2, delta: float) -> void:
	if motor_damp_start_speed == -1:
		motor_damp_start_speed = motor_velocity.length()
	var base_mult: float = motor_vec.length()/ MOTOR_DAMP_DISTANCE
	motor_velocity *= pow(0.2+base_mult*0.8, delta)
	var mult: float = pow(base_mult, 0.5)
	var mv_target := motor_vec.normalized()*base_mult*motor_damp_start_speed
	var acc := MOTOR_ACC1*sqrt(motor_velocity.length())
	motor_velocity = motor_velocity.move_toward(mv_target, acc*delta)

func apply_motor_velocity(delta: float) -> void:
	$ConeJoint.swing_motor_target_velocity_z = motor_velocity.x
	$ConeJoint.swing_motor_target_velocity_y = -motor_velocity.y

func get_motor_velocity() -> void:
	motor_velocity.x = $ConeJoint.swing_motor_target_velocity_z
	motor_velocity.y = -$ConeJoint.swing_motor_target_velocity_y


# from 0 to 2 (what euclidian distance would be with radius one) 
func arm_distance(apA: ArmPosition, apB: ArmPosition) -> float:
	var a := spherical_to_cartesian(1.0, apA.theta, apA.ro)
	var b := spherical_to_cartesian(1.0, apB.theta, apB.ro)
	return (a-b).length()

func arm_polar_direction(from: ArmPosition, to: ArmPosition) -> Vector2:
	var from_length := from.ro*10
	var to_length := to.ro*10
	var polar_from := Vector2(cos(from.theta), sin(from.theta)) * from_length
	var polar_to := Vector2(cos(to.theta), sin(to.theta)) * to_length
	return (polar_to - polar_from).normalized()

func spherical_to_cartesian(r: float, theta: float, ro: float) -> Vector3:
	var x := r*sin(ro)*cos(theta)
	var y := r*sin(ro)*sin(theta)
	var z := r*cos(ro)
	return Vector3(x,y,z)

func target_arm_position(stick: Vector2, trig: float) -> ArmPosition:
	var ap := ArmPosition.new()
	# from stick
	var s_ro := (PI/180.) * MAX_ANGLE * stick.length()
	var s_theta := atan2(stick.y, stick.x)
	# from trig
	var t_ro := 0.0
	var t_theta := atan2(remembered_stick.y, remembered_stick.x)
	# add stick and trig together
	ap.ro = s_ro + t_ro
	if ap.ro < 0.000000001:
		return ap
	ap.theta = s_theta*(s_ro/ap.ro) + t_theta*(t_ro/ap.ro)
	return ap

#func local_position

# returns Vector2(theta, ro) where theta corresponds to the direction of the 
# arm and ro corresponds to the depth of the arm i.e how far it is swung from 
# starting position
func current_arm_position() -> ArmPosition:
	var thetaro := ArmPosition.new()
	var qq: Vector3 = $ConeJoint.basis * Vector3.UP
	var pos: Vector3 = $Arm.position
	var r := sqrt(pos.x*pos.x + pos.y*pos.y + pos.z*pos.z)
	thetaro.ro = acos(pos.y/r)
	thetaro.theta = atan2(-pos.z, pos.x)
	return thetaro

func easy_print_v3(v: Vector3) -> void:
	if owner == null:
		return
	print("<%.2f, %.2f, %.2f>" % [v.x, v.y, v.z])
	
