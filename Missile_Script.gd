extends Node3D

@export var gravity = Vector3.DOWN * 36

var velocity = Vector3.ZERO

var explosion = preload("res://explosion.tscn")


func _ready():
	# We want to get the area and connect ourself to it's body_entered signal.
	# This is so we can tell when we've collided with an object.
	$Rocket_sound.play()
	

func _physics_process(delta):
	velocity += gravity * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta


func _on_area_body_entered(_body):
	explode()
	

func explode():
	var clone = explosion.instantiate()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)
	clone.transform = global_transform
	clone.scale = Vector3(8, 8, 8)
	queue_free()

func get_hit(_damage):
	explode()
