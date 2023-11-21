extends CharacterBody3D

var animated_sprite_3d 
var p_timer
var reload_timer
var player : CharacterBody3D
var node_clshape
var Chase_Area3D
var pattack_range
var instantdeath_range
var blood_timer
var blood_splat_spot

##Turn music off
@export var music_toggled_off : bool = false


	#Speed and direction and target Vars
##monster current move speed
@export var move_speed : float = 6.0
##Can enemy move yes or no?
@export var move : bool = false
##G for Gravity
@export var gravity = Vector3.DOWN * 16
##Fresh means monster has not be activated for the first time
@export var fresh : bool = true


var blood_time : bool = true
var current_target  = null
var cam 
var cam_pos

	#Health Vars
##Enemy Current health
@export var enemy_health : int 
##Enemy MAX health
@export var ENEMY_MAX_HEALTH :int = 1000
##Is monster dead yes or no
@export var dead : bool = false
##Is monster death animation playing?
@export var is_dying :bool = false

	#Attack Vars
@export var can_shoot : bool = true
##Ammo of range attack until reload
##current enemy range
@export var attack_range : float = 2
##enemy able to physically attack
@export var can_pattack : bool = false
##is player or target in enemy's range?
@export var in_p_attack_range : bool
##Physical attack damage
@export var p_damage = 20
##Missle attack damage
@export var TURRET_MISSILE_SPEED : int = 14
@export var TURRET_BARREL_SPEED : int = 10
@export var missile_velocity : int = 15
@export var barrel_velocity : int = 4


var missile_scene = preload("res://Missile_Scene.tscn")
var barrel_scene = preload("res://Barrel_Scene.tscn")
var blood_decal = preload("res://blood_decal.tscn")
var blood_particles = preload("res://blood_particles.tscn")


func _process(delta):
	movement(delta)
	
func enemy_readyup():
	
	animated_sprite_3d = $AnimatedSprite3D
	p_timer = $P_Timer
	player = get_tree().get_first_node_in_group("player")
	node_clshape = $CollisionShape3D
	Chase_Area3D = $Chase_Area3D/CollisionShape3D
	pattack_range = $pattack_range/CollisionShape3D
	instantdeath_range = $instantdeath_range/CollisionShape3D
	blood_timer = $Blood_Timer
	blood_splat_spot = $blood_splat_spot
	
	cam = get_viewport().get_camera_3d();
	enemy_health = ENEMY_MAX_HEALTH


func movement(delta):
		# When fresh allow enemy to have gravity to stay on ground
	if fresh:
		velocity += gravity * delta
		move_and_slide()

		# If monster is dead do not do anything.
	if dead:
		return
	if player == null:
		return

		# Turn player position into direction to go
	var dir = player.global_position - global_position
	dir.y = 0
	dir = dir.normalized()

		# When activated and can move look at player and move towards them
	if move:
		velocity = dir * move_speed
		velocity.y = -16
		move_and_slide()


		# Monster attack to the player
func attack():

	# if the player is dead stop attacking
	if player.player_dead:
		return

		# Play monster attack sounds
	Audio.play("sounds/enemy/base/attack1.wav, sounds/enemy/base/attack2.wav, sounds/enemy/base/attack3.wav, sounds/enemy/base/attack4.wav")
	player.get_hit()


	# Monster gets hit
func get_hit(damage):
	
	# lower enemy health
	enemy_health -= damage
	
		#spawn blood decal
	var blood_splat = blood_decal.instantiate()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(blood_splat)
	blood_splat.transform = global_transform
	
		# blood time controls if blood particles will spray
	if blood_time:
		spawn_blood_spray()
		
		#If enemy has no health kill em.
	if enemy_health <= 0:
		kill()
	if dead: return
	
	# play enemy gets hit sound
	Audio.play("sounds/enemy/base/get_hit1.wav, sounds/enemy/base/get_hit2.wav, sounds/enemy/base/get_hit3.wav, sounds/enemy/base/get_hit4.wav")
	



	#Monster death function. Play death animation, emit blood, play sound ect ect
func kill():
	
	# If dead do nothing
	if dead:
		return
	
	# - disable all sprites and areas
	animated_sprite_3d.dead = true
	Chase_Area3D.disabled = true
	instantdeath_range.disabled = true
	pattack_range.disabled = true
	animated_sprite_3d.billboard = true
	velocity *= 0
	
	# play death sound
	$Deathsound.play()
	# play death animation
	animated_sprite_3d.play("death")
	await animated_sprite_3d.animation_finished
	
	
	dead = true
	
	#Spawn blood Particles
	spawn_blood_spray()

	# instant death range, this is if player fully touches monster
func _on_instantdeath_range_body_entered(body):
	if body.name == "Player":
		in_p_attack_range = true
		player.kill()


	# Phyisical attack if in pattack range
func _on_p_timer_timeout():
	can_pattack = true
	#p_timer.start()
	if can_pattack && in_p_attack_range:
		player.get_hit(p_damage)
	can_pattack = false


	# Physical attack Range
func _on_pattack_range_body_entered(body):
	#Start Phsyical attack timer
	p_timer.start()
	if body.name == "Player":
		in_p_attack_range = true
		animated_sprite_3d.ranged_active = false
		Audio.play("sounds/enemy/base/attack1.wav, sounds/enemy/base/attack2.wav, sounds/enemy/base/attack3.wav, sounds/enemy/base/attack4.wav")
	

	# Leaving phsyical attack range
func _on_pattack_range_body_exited(body):
	if body.name == "Player":
		in_p_attack_range = false
		animated_sprite_3d.ranged_active = true
		p_timer.stop()

func fire_missile():
		# Clone the missiles, get the scene root, and add the missile as a child.
		# NOTE: we are assuming that the first child of the scene's root is
		# the 3D level we're wanting to spawn the missiles at.
	var missile = missile_scene.instantiate()
	var missile2 = missile_scene.instantiate()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(missile)
	scene_root.add_child(missile2)
		# Set the missile's global_transform to that of the Missile spawn point (which is this node).
	missile.transform = $AnimatedSprite3D/Head/Missile_End.global_transform
	missile.velocity = -missile.transform.basis.z * missile_velocity
	missile2.transform = $AnimatedSprite3D/Head/Missile_End2.global_transform
	missile2.velocity = -missile2.transform.basis.z * missile_velocity

		# The missile's are a little too small (by default), so let's make it bigger!
	missile.scale = Vector3(1, 1, 1)
	missile2.scale = Vector3(1, 1, 1)

		# Clone the barrels, get the scene root, and add the missile as a child.
		# NOTE: we are assuming that the first child of the scene's root is
		# the 3D level we're wanting to spawn the barrels at.
	var barrel = barrel_scene.instantiate()
	var barrel2 = barrel_scene.instantiate()
	scene_root.add_child(barrel)
	scene_root.add_child(barrel2)
		# Set the barrel's global_transform to that of the pistol spawn point (which is this node).
	barrel.transform = $AnimatedSprite3D/Head/Barrel_End.global_transform
	barrel.velocity = -barrel.transform.basis.z * barrel_velocity
	barrel2.transform = $AnimatedSprite3D/Head/Barrel_End2.global_transform
	barrel2.velocity = -barrel2.transform.basis.z * barrel_velocity
	
		# The barrels are a little too small (by default), so let's make it bigger!
	barrel.scale = Vector3(1, 1, 1)
	barrel2.scale = Vector3(1, 1, 1)


func _on_blood_timer_timeout():
		# Blood Particles controller to limit blood spary to blood time
	blood_time = true
	
func spawn_blood_spray():
		# Spawn blood spray (particle)
	var blood_spray = blood_particles.instantiate()
	add_child(blood_spray)

	#Timer to limit amount of particles spray per few seconds
	blood_time = false
	blood_timer.start()
	
func play_music():
	$AnimatedSprite3D/music.play()
	
func stop_music():
	$AnimatedSprite3D/music.stop()
