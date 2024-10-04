@tool
extends RigidBody3D

@export var BASE_FORCE := 400.0 # when dist == 0
@export var HALF_LIFE := 0.025
@export var MAG_TARG_SPEED := 10.0
# TODO: max force and halflife
const STABLE_DISTANCE := 0.2

#@export var cupping := 10.0 :
	#set(value):
		#cupping = value
		#if !has_node("Shape"):
			#return
		#$Shape.rotation.x = cupping*(PI/180.0)
		#$Shape2.rotation.x = -cupping*(PI/180.0)
		#$Shape3.rotation.z = cupping*(PI/180.0)
		#$Shape4.rotation.z = -cupping*(PI/180.0)

var bodies: Array[RigidBody3D] = []
var attraction := 0.0

func _ready() -> void:
	linear_damp = 30.0


func _physics_process(delta: float) -> void:
	if attraction != 0.0:
		attract_bodies(delta)

func set_attraction(a: float) -> void:
	attraction = a*abs(a)

func attract_bodies(delta: float) -> void:
	for b: RigidBody3D in bodies:
		if attraction > 0.0:
			attract_body(b, delta)
		else:
			push_body(b)
			

func attract_body(body: RigidBody3D, delta: float) -> void:
	var to_body: Vector3 = body.global_position - $Target.global_position
	var toward_body := to_body.normalized()
	var dist := to_body.length()
	var e_dist: float = max(0.0, dist - 0.5)
	var mult := HALF_LIFE/(HALF_LIFE+e_dist)
	if dist < STABLE_DISTANCE:
		damp_body(body, 0.95, delta)
		mult *= pow(dist/STABLE_DISTANCE, 1.0)
	#mult *= abs((global_basis.inverse() * toward_body).dot(Vector3.UP))
	var force := toward_body * mult * BASE_FORCE * attraction
	body.apply_force(-force)
	damp_body(body, 0.15, delta)
	if $Target.position.y < 0.3:
		apply_force(force)

func damp_body(body: RigidBody3D, damping: float, delta: float) -> void:
	var bv := body.linear_velocity
	if bv.length() < 2.0:
		return
	var mult := pow(1.0-damping, delta*bv.length())
	body.apply_impulse(-bv.normalized()*damping)

func push_body(body: RigidBody3D) -> void:
	var to_body: Vector3 = body.global_position - $Target.global_position
	var outward := global_basis * Vector3.UP
	var dist := to_body.length()
	dist = max(0.0, dist - 0.5)
	var mult := HALF_LIFE/(HALF_LIFE+dist)
	var force := outward * mult * BASE_FORCE * attraction
	body.apply_force(-force)
	apply_force(force)

# TODO: launch body and tug body, apply impulse
# will damp current momentum and therefore not be useful for throwing
# maybe push body should have an attribute that makes it better for throwing?


func mag_distance(d: float, delta: float) -> void:
	$Target.position.y = move_toward($Target.position.y, d, MAG_TARG_SPEED*delta)


func _on_detection_area_body_entered(body: Node3D) -> void:
	print(str(body) + " entered")
	if !body is PhysicsBody3D:
		return
	bodies.append(body)


func _on_detection_area_body_exited(body: Node3D) -> void:
	print(str(body) + " exited")
	if !body is PhysicsBody3D:
		return
	bodies.erase(body)
