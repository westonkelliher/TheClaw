extends RigidBody3D


@export var SPEED := 0.1
@export var ACC := 0.3
@export var TURN_SPEED := 0.5

var target := Vector3.ZERO
var angle_offset := 0.0

var gravity := 9.8

func _physics_process(delta: float) -> void:
	turn_toward_target(delta)
	walk_forward(delta)
	if has_fallen() and $DeathTimer.is_stopped():
		$Mesh.mesh = $Mesh.mesh.duplicate()
		$HeadMesh.mesh = $HeadMesh.mesh.duplicate()
		$Mesh.mesh.material = preload("res://materials/enemy_hurt.tres")
		$HeadMesh.mesh.material = preload("res://materials/enemy_hurt.tres")
		$DeathTimer.start()

func walk_forward(delta: float) -> void:
	var forward := (basis * Vector3.FORWARD).normalized()
	var fric_force := mass*physics_material_override.friction*gravity
	apply_force(forward*fric_force, $FootSpot.position)
	if linear_velocity.dot(forward) < SPEED:
		# take off 1*ACC in current direction and add 2*ACC forward
		apply_force(-linear_velocity.normalized()*ACC)
		apply_force(2*forward*ACC)

func turn_toward_target(delta: float) -> void:
	var angle_to_target := angle_to_target()
	apply_torque(Vector3(0.0, -angle_to_target, 0.0)*0.5)

func angle_to_target() -> float:
	var forward := (basis * Vector3.FORWARD).normalized()
	var f_2d := Vector2(forward.x, forward.z)
	var target_forward := (target - global_position).normalized()
	var tf_2d := Vector2(target_forward.x, target_forward.z)
	#print(str(f_2d)+" " +str(tf_2d))
	var angle_to_target := tf_2d.angle() - f_2d.angle()
	if angle_to_target > PI:
		angle_to_target -= 2*PI
	if angle_to_target < -PI:
		angle_to_target += 2*PI
	return angle_to_target
	

func has_fallen() -> bool:
	return $FootSpot.global_position.y > 0.35

func standup() -> void:
	pass

func is_standing() -> bool:
	return abs($FootSpot.y) < 0.02


func _on_death_timer_timeout() -> void:
	queue_free()
