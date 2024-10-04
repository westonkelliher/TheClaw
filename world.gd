extends Node3D

const MAX_CAM_SPEED := 5.0
const CAM_ACC := 15.0
var cam_speed := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$EnemySpawner.owner = self


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("pad_left"):
		cam_speed = move_toward(cam_speed, MAX_CAM_SPEED, CAM_ACC*delta)
	elif Input.is_action_pressed("pad_right"):
		cam_speed = move_toward(cam_speed, -MAX_CAM_SPEED, CAM_ACC*delta)
	else:
		cam_speed = 0.0
	rotate_camera(cam_speed, delta)
		

func rotate_camera(a: float, delta: float) -> void:
	$CamPivot.rotation.y += a * delta
	$DualArm.set_cam_rotation($CamPivot.rotation.y)
