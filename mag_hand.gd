extends RigidBody3D

@export var BASE_FORCE := 30.0 # when dist == 1

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
		var pow := 2.1 + attraction
		var mult := pow(1/(dist+0.03), pow)
		mult *= abs((global_basis.inverse() * toward_body).dot(Vector3.UP))
		var force := toward_body * pow(1/(dist+0.03), 2.0) * BASE_FORCE * attraction
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
