extends Arm


func _ready() -> void:
	$Arm/ForeArm.attached_to = ".."
	$Arm/ForeArm/StapleJoint.node_a = "../Arm"
	if owner == null: # scene being tested standalone
		add_test_camera()
	pass


func _physics_process(delta: float) -> void:
	var gpi := InputHandler.get_gamepad_input()
	var base_stick_L := gpi.stick_L
	var agreement: float = max(0.0, gpi.stick_L.dot(gpi.stick_R))
	var disagreement: float = min(0.0, gpi.stick_L.dot(gpi.stick_R))
	print(disagreement)
	print(agreement)
	handle_input(gpi.stick_L*(1.0-agreement*0.5), 0.0, delta)
	#print($Arm/ForeArm.global_position)
	$Arm/ForeArm.handle_input(gpi.stick_R*(1.0+disagreement*0.2), 0.0, delta)
	if Input.is_action_just_pressed("RB"):
		$Arm/ForeArm/MagHand.set_attraction(1.0)
	if Input.is_action_just_released("RB"):
		$Arm/ForeArm/MagHand.set_attraction(0.0)
	if Input.is_action_just_pressed("LB"):
		$Arm/ForeArm/MagHand.set_attraction(-1.0)
	if Input.is_action_just_released("LB"):
		$Arm/ForeArm/MagHand.set_attraction(0.0)
	$Arm/ForeArm/MagHand.set_attraction(gpi.trig_R)
	if gpi.trig_L != 0.0:
		$Arm/ForeArm/MagHand.set_attraction(-gpi.trig_L)
