extends Arm


func _ready() -> void:
	$Arm/ForeArm.attached_to = ".."
	if owner == null: # scene being tested standalone
		add_test_camera()
	pass


func _physics_process(delta: float) -> void:
	var gpi := InputHandler.get_gamepad_input()
	handle_input(gpi.stick_L, gpi.trig_L, delta)
	#print($Arm/ForeArm.global_position)
	$Arm/ForeArm.handle_input(gpi.stick_R, gpi.trig_R, delta)
