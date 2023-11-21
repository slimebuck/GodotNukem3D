extends Node3D

@export var car_health : int = 21

var explosion = preload("res://explosion.tscn")

func get_hit(damage):
	# To prevent barrels from exploding to fire on the ground, check damage done
	# If under weakest weapon, do not explode
	if damage >= car_health:
		pass
		var clone = explosion.instantiate()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)
		clone.transform = global_transform
		clone.scale = Vector3(8, 8, 8)
		$"../../..".queue_free()
