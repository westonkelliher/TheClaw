extends Node3D

const SPAWN_HEIGHT  := 0.7
const SEED := 102412042
@export var MIN_RADIUS := 20.0
@export var MAX_RADIUS := 50.0

var N := 1



func _on_timer_timeout() -> void:
	var p := determine_spawn_location(N)
	spawn_enemy_at(p)
	N += 1


func spawn_enemy_at(p: Vector3) -> void:
	var enemy := preload("res://enemies/cultist.tscn").instantiate()
	enemy.position = p
	var targ: Vector3 = (enemy.target - p)
	enemy.rotation.y = Vector2(targ.x, targ.y).angle()
	print("Spawning at "+str(p))
	add_child(enemy)

func determine_spawn_location(n: int) -> Vector3:
	var subseed := pow(n, 2)*(SEED+555555)
	var angle := fmod(subseed*0.01,PI*2)
	var dist := MIN_RADIUS + (MAX_RADIUS-MIN_RADIUS)*fmod(subseed*0.00001, 1.0)
	var loc := Vector2.RIGHT.rotated(angle)*dist
	return Vector3(loc.x, SPAWN_HEIGHT, loc.y)
