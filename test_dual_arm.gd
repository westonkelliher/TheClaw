extends TestArmSegment


func _ready() -> void:
	print("dualarm ready with owner: "+str(owner))
	if owner == null: # scene being tested standalone
		add_test_camera()
	pass


func _physics_process(delta: float) -> void:
	print()
	var gpi := InputHandler.get_gamepad_input()
	handle_input(gpi.stick_L, gpi.trig_L, delta)
	print($Arm/TestArmSegment.global_position)
	$Arm/TestArmSegment.handle_input(gpi.stick_R, gpi.trig_R, delta)
