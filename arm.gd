extends Node3D


func _ready() -> void:
	if owner == null: # scene being tested standalone
		add_test_camera()
	pass

## Testing ##
func add_test_camera() -> void:
	print("WARNING: Adding test camera to arm")
	var cam := Camera3D.new()
	cam.position = Vector3(0.0, 0.0, 3.0)
	get_parent().add_child.call_deferred(cam)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var gpi := InputHandler.get_gamepad_input()
	$BaseArm.handle_input(gpi.stick_L, gpi.trig_L, delta)
	$.handle_input(gpi.stick_R, gpi.trig_R, delta)
