extends Arm


func _ready() -> void:
	$Arm/ForeArm.attached_to = ".."
	$Arm/ForeArm/StapleJoint.node_a = "../Arm"
	if owner == null: # scene being tested standalone
		add_test_camera()
	pass


func _physics_process(delta: float) -> void:
	var gpi := InputHandler.get_gamepad_input()
	handle_input(gpi.stick_L, gpi.trig_R, delta)
	#print($Arm/ForeArm.global_position)
	$Arm/ForeArm.handle_input(gpi.stick_R, gpi.trig_R, delta)
	if Input.is_action_just_pressed("LB"):
		$Arm/ForeArm/MagHand.set_on_off(true)
	if Input.is_action_just_released("LB"):
		$Arm/ForeArm/MagHand.set_on_off(false)
