@tool
extends Arm


func _ready() -> void:
	$Arm/ForeArm.attached_to = ".."
	$Arm/ForeArm/MagHand/StapleJoint.node_a = "../../Arm"
	if owner == null: # scene being tested standalone
		add_test_camera()
	pass


func _physics_process(delta: float) -> void:
	if !InputMap.has_action("LB"):
		return
	var gpi := InputHandler.get_gamepad_input()
	var base_stick_L := gpi.stick_L
	var agreement: float = max(0.0, gpi.stick_L.dot(gpi.stick_R))
	var disagreement: float = min(0.0, gpi.stick_L.dot(gpi.stick_R))
	handle_input(gpi.stick_L*(1.0-agreement*0.5), 0.0, delta)
	#print($Arm/ForeArm.global_position)
	$Arm/ForeArm.handle_input(gpi.stick_R*(1.0+disagreement*0.2), 0.0, delta)
	$Arm/ForeArm/MagHand.set_attraction(0)
	if gpi.trig_R != 0.0:
		print(gpi.trig_R)
		$Arm/ForeArm/MagHand.set_attraction(gpi.trig_R)
	if gpi.trig_L != 0.0:
		$Arm/ForeArm/MagHand.set_attraction(-gpi.trig_L*0.5)
	if Input.is_action_pressed("RB"):
		$Arm/ForeArm/MagHand.set_attraction(4.0)
	if Input.is_action_pressed("LB"):
		$Arm/ForeArm/MagHand.set_attraction(-2.0)
