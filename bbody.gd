extends RigidBody3D

var explosion = preload("res://explosion.tscn")

##Is the barrel present in scene aka alive?
@export var barrel_alive : bool = true

##ammount of health barrel has until explosion
@export var barrel_health : int = 5

@export var projectile : bool = false

func _ready():
	pass

func _process(_delta):
	pass

func get_hit(damage):
	# To prevent barrels from exploding to fire on the ground, check damage done
	# If under weakest weapon, do not explode
	if damage >= barrel_health:
		pass
		var clone = explosion.instantiate()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)
		clone.transform = global_transform
		clone.scale = Vector3(8, 8, 8)
		barrel_alive = false
		#$"..".visible = false
		if projectile:
			$"../Kill_Timer".stop()
		queue_free()



func _on_area_3d_body_entered(body):
	if body == self: return
	if projectile:
		if body.is_in_group("player") or body.is_in_group("barrel") or body.is_in_group("car"):
			get_hit(20)
