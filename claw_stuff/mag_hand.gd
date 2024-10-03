@tool
extends RigidBody3D

@export var BASE_FORCE := 500.0 # when dist == 0
@export var HALF_LIFE := 0.025
# TODO: max force and halflife

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


func _physics_process(delta: float) -> void:
	if attraction != 0.0:
		attract_bodies(delta)

func set_attraction(a: float) -> void:
	attraction = a*abs(a)

func attract_bodies(delta: float) -> void:
	for b: RigidBody3D in bodies:
		var to_body := b.global_position - global_position
		var toward_body := to_body.normalized()
		var dist := to_body.length()
		dist = max(0.0, dist - 0.5)
		var mult := HALF_LIFE/(HALF_LIFE+dist)
		mult *= abs((global_basis.inverse() * toward_body).dot(Vector3.UP))
		var force := toward_body * mult * BASE_FORCE * attraction
		print("--")
		print(BASE_FORCE)
		print(attraction)
		print(force.length())
		print("-----")
		#print(force)
		b.apply_force(-force)
		apply_force(force)


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
