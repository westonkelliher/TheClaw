@tool
extends Arm

var cam_rotation := 0.0

var MAG_EXTENT := 1.0

var UNDERPOWER := true

var SHOT_POWER := 2.0

func _ready() -> void:
	$Arm/ForeArm.attached_to = ".."
	$Arm/ForeArm/MagHand/StapleJoint.node_a = "../../Arm"
	if owner == null: # scene being tested standalone
		add_test_camera()
	if UNDERPOWER:
		#MOTOR_VELOCITY = 60.0
		#$Arm/ForeArm.MOTOR_VELOCITY = 100.0
		MAG_EXTENT = 0.6
		SHOT_POWER = 0.5
		$Arm/ForeArm/MagHand.BASE_FORCE = 200.0
		$Arm/ForeArm/MagHand.MAG_TARG_SPEED = 2.0
	#
	#MAX_MOTOR1 = 0.5
	#MAX_MOTOR2 = 1.0


func _physics_process(delta: float) -> void:
	if !InputMap.has_action("LB"):
		return
	var gpi := InputHandler.get_gamepad_input().rotated(cam_rotation)
	var base_stick_L := gpi.stick_L
	var agreement: float = max(0.0, gpi.stick_L.dot(gpi.stick_R))
	var disagreement: float = min(0.0, gpi.stick_L.dot(gpi.stick_R))
	handle_input(gpi.stick_L*(1.0-agreement*0.4), 0.0, delta)
	#print($Arm/ForeArm.global_position)
	$Arm/ForeArm.handle_input(gpi.stick_R*(1.0+disagreement*0.2), 0.0, delta)
	extend_mag(gpi.trig_L, delta)
	$Arm/ForeArm/MagHand.set_attraction(0)
	if gpi.trig_R != 0.0 and !Input.is_action_pressed("LB"):
		$Arm/ForeArm/MagHand.set_attraction(gpi.trig_R)
	#if gpi.trig_L != 0.0:
		#$Arm/ForeArm/MagHand.set_attraction(-gpi.trig_L*0.8)
	if Input.is_action_just_pressed("RB"):
		$Arm/ForeArm/MagHand.shoot_bodies(SHOT_POWER)
	if Input.is_action_just_pressed("LB"):
		$Arm/ForeArm/MagHand.shoot_bodies(-SHOT_POWER)

func set_cam_rotation(a: float) -> void:
	cam_rotation = a


func extend_mag(amount: float,delta: float) -> void:
	$Arm/ForeArm/MagHand.mag_distance(0.0 + amount*MAG_EXTENT, delta)
