extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	$Timer.wait_time = 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if position.length() > 6.0 and $Timer.is_stopped():
		#print("yea")
		#$Timer.start()
	if position.length() > 5.7:
		if linear_velocity.length() < 0.1 and $Timer.is_stopped():
			$Timer.start()
	
	if position.length() > 90.0:
		position = position*0.9
		position.y = 0.5
		linear_velocity = Vector3.ZERO


func _physics_process(delta: float) -> void:
	apply_torque(angular_velocity.normalized()*-0.2)

func _on_timer_timeout() -> void:
	apply_impulse(-position/sqrt(position.length()), Vector3.ONE*0.1)
