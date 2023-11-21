extends Node3D

	# Onreadys
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var high_damage_col = $high_damage_Area3D/high_damage_col
@onready var low_damage_col = $low_damage_Area3D/low_damage_col



	#Damage Vars
##close to explosion damage
@export var low_damage : int = 22

##direct hit damage
@export var high_damage : int = 50

var damage : int

	# preloads
var fire_scene = preload("res://fire_area.tscn")
var crater_decal = preload("res://crater_decal.tscn")
var boom_sound = preload("res://boom_sound.tscn")

func _ready():
		# Play explosion sound
	var boom = boom_sound.instantiate()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(boom)
		# Place blood spray and splat
	boom.transform = global_transform
		#Play explosion Animatiom
	$Explosion_Node/Animated_Explosion.play("Boom")


func _process(_delta):
	pass

	# High damage hit if direct hit to player, or very close
func _on_high_damage_area_3d_body_entered(body):

	if body.has_method("get_hit"):
		high_damage_col.queue_free()
		low_damage_col.queue_free()
		if body.is_in_group("player") or body.is_in_group("barrel") or body.is_in_group("car"): 
			low_damage_col.queue_free()
			damage = high_damage
			body.get_hit(damage)


	# a weaker hit if player is close to explosion but not right beside
func _on_low_damage_area_3d_body_entered(body):
	damage = low_damage
	high_damage_col.queue_free()
	low_damage_col.queue_free()
	if body.has_method("get_hit"):
		if body.is_in_group("player") or body.is_in_group("barrel"):
			body.get_hit(damage)



func _on_animated_explosion_animation_finished():
	
		# Spawn blood spat (decal) and spray (particle)
	var fire = fire_scene.instantiate()
	var crater = crater_decal.instantiate()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(fire)
	scene_root.add_child(crater)
		# Place blood spray and splat
	fire.transform = global_transform
	crater.transform = global_transform

	#await $Boom_sound.finished
	queue_free()

