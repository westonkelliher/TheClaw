#@tool
extends Node3D
class_name TestArmSegment

class ArmPosition:
	var theta := 0.0
	var ro := 0.0


@export var MAX_ANGLE_FROM_STICK := 60.0
@export var MAX_ANGLE_FROM_TRIG := 70.0
@export var LENGTH := 1.8 :
	set(value):
		LENGTH = value
		if !has_node("Shape"):
			return
		$Shape.shape = $Shape.shape.duplicate()
		$Shape.shape.height = LENGTH+0.2
		$Mesh.mesh = $Mesh.mesh.duplicate()
		$Mesh.mesh.height = LENGTH+0.2
		$End.position.y = LENGTH/2.0
		$Fins.scale.y = LENGTH
		$Fins2.scale.y = LENGTH
	get:
		return LENGTH


@export var MOTOR_VELOCITY := 100.0 # not sure of the units
@export var MOTOR_DAMP_DISTANCE := 0.5 # measured in radians



@export var attached_to: NodePath = "":
	set(value):
		$ConeJoint.node_a = NodePath("../" + str(value))
		attached_to = value
	get:
		return $ConeJoint.node_a

const REMEMBER_THRESHOLD := 0.1



var remembered_stick_vec := Vector2.RIGHT
var arm_vector := Vector3.UP

func _ready() -> void:
	print("ready with owner: "+str(owner))
	if owner == null: # scene being tested standalone
		add_test_camera()
	pass

func _physics_process(delta: float) -> void:
	if owner == null: # scene being tested standalone
		test_input(delta)
	pass

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
	if owner != null:
		print("handling stick: " + str(stick))
	var current := current_arm_position()
	var targ := target_arm_position(stick, trig)
	motor_towards_position(current, targ, delta)
	#return

#TODO: take the difference between current cylindrical coords and desired

func motor_towards_position(from: ArmPosition, to: ArmPosition, delta: float) -> void:
	#print(to.theta)
	var direction := arm_polar_direction(from, to)
	var dist := arm_distance(from, to)
	var mult: float = MOTOR_VELOCITY * sqrt(min(dist, MOTOR_DAMP_DISTANCE) / MOTOR_DAMP_DISTANCE)
	$ConeJoint.swing_motor_target_velocity_z = direction.x * mult * delta
	$ConeJoint.swing_motor_target_velocity_y = -direction.y * mult * delta

# from 0 to 2 (what euclidian distance would be with radius one) 
func arm_distance(apA: ArmPosition, apB: ArmPosition) -> float:
	var a := spherical_to_cartesian(1.0, apA.theta, apA.ro)
	var b := spherical_to_cartesian(1.0, apB.theta, apB.ro)
	return (a-b).length()

func arm_polar_direction(from: ArmPosition, to: ArmPosition) -> Vector2:
	var from_length := from.ro
	var to_length := to.ro
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
	var s_ro := (PI/180.) * MAX_ANGLE_FROM_STICK * stick.length()
	var t_ro := (PI/180.) * MAX_ANGLE_FROM_TRIG * trig
	ap.ro = s_ro + t_ro
	ap.theta = atan2(stick.y, stick.x)
	return ap

#func local_position

# returns Vector2(theta, ro) where theta corresponds to the direction of the 
# arm and ro corresponds to the depth of the arm i.e how far it is swung from 
# starting position
func current_arm_position() -> ArmPosition:
	#print(basis.y)
	var thetaro := ArmPosition.new()
	var qq: Vector3 = $ConeJoint.basis * Vector3.UP
	var pos: Vector3 = $Arm.position
	easy_print_v3(pos)
	var r := sqrt(pos.x*pos.x + pos.y*pos.y + pos.z*pos.z)
	thetaro.ro = acos(pos.y/r)
	thetaro.theta = atan2(-pos.z, pos.x)
	return thetaro

func easy_print_v3(v: Vector3) -> void:
	if owner == null:
		return
	print("<%.2f, %.2f, %.2f>" % [v.x, v.y, v.z])
	
