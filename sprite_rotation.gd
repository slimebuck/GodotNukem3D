extends AnimatedSprite3D

var music_notplaying : bool = true

	#onready varables to connect nodes for code use
var enemy : CharacterBody3D
var player : CharacterBody3D
var animated_sprite_3d : AnimatedSprite3D
var timer : Timer
var lookpoint

	#basic vars for sprite direction code. Camera location, angle to cam, lookpoint stuff
var cam 
var cam_pos
var look_point_pos 
var look_point_dir
var cam_dir
var angle_to_cam
var angle_to_lookpoint
var chase : bool = false

##Direction to player from enemy in degrees.
@export var enemy_angle : float


##Direction to player from enemy in String form.
@export var angle : String
##Monster is ranged_active, ie: moving, or attacking
@export var ranged_active = false
##Monster is idle
@export var idle = true
##Can the monster shoot, if true fire_missile() when ranged_active
@export var can_shoot : bool = true
##checks Ray_Cast, if collider has handle_controls() use get_hit()
@export var ranged_attacking : bool = false
##Monster is dying
@export var is_dyiing : bool = false
##Monster is dead
@export var dead : bool = false
##Is player dead or alive
@export var player_dead : bool = false
##Boss theme song
@export var music_scene = preload("res://music_scene_2.tscn")


func sprite_rot_readyup():
	enemy = $".."
	player = get_tree().get_first_node_in_group("player")
	animated_sprite_3d = $"."
	timer = $"../Timer"
	lookpoint = $"../Lookpoint"

	
		# Get the player's camera
	cam = get_viewport().get_camera_3d();
	look_point_pos = lookpoint.global_position 
	look_point_pos = look_point_pos.normalized()


	
func idle_to_chase():
	# If Monster is dead do nothing
	if dead: return

	# If monster is Idle look at starting lookpoint
	if idle:
		look_point_pos = lookpoint.global_position 

	# If Monster is ranged_active look at player -raycast collider has handle_controls()
	if chase:
		look_point_pos = player.global_position 
		if can_shoot:
			if ranged_active:
				ranged_attack()

	# Normalize lookpoint position, get lookpoint direction
	look_point_pos = look_point_pos.normalized()

	look_point_dir = position - look_point_pos

	# Billboards the sprite so it always looks at the player
	cam_pos = cam.global_transform.origin
	look_at(cam_pos, Vector3(0, 1, 0))
	rotation.x = 0

	# Calculate the angle of the sprite, taking into consideration both the object the sprite is looking at
	# and the position of the camera, and convert the radians to degrees for more human friendly readability
	cam_dir = position - cam_pos
	angle_to_cam = rad_to_deg(atan2(cam_dir.x, cam_dir.z))
	angle_to_lookpoint = rad_to_deg(atan2(look_point_dir.x, look_point_dir.z))
	
	enemy_angle = angle_to_cam - angle_to_lookpoint
	
	
	# Fix negative degrees
	if enemy_angle < 0:
		enemy_angle += 360

	chase_anim()
	
	
func chase_anim():

	# Here I split up the angle in nice equal chunks so we get 8 even segments for an
	# 8-directional sprite, like most classic FPS games!
	# Feel free to multiply/divide the statements if
	# you want something like only 4-directions or even 16 or more, the limit is your
	# imagination/hardware!
	
	# Depending on enemy angle show coresponding animation.
	# degrees 0 - 22.5 = front
	# degrees 22.6 to 67.5 = front right
	# degrees  67.6 to 112.5
	# degrees 112.6 to 157.5
	# degrees 157.6 to 202.5
	# degrees 202.6 to 247.5
	# degrees 247.6 to 292.5
	# degrees 292.6 to 337.5
	# degrees 337.6 to 360
	
	if ranged_attacking:
		if animated_sprite_3d.is_playing(): return

	if enemy_angle >= 292.5 && enemy_angle < 337.5:
		play("front_left")
		angle = "front_left"
	elif enemy_angle >= 22.5 && enemy_angle < 67.5:
		play("front_right")
		angle = "front_right"
	elif enemy_angle >= 67.5 && enemy_angle < 112.5:
		play("right")
		angle = "right"
	elif enemy_angle >= 112.5 && enemy_angle < 157.5:
		play("back_right")
		angle = "back_right"
	elif enemy_angle >= 157.5 && enemy_angle < 202.5:
		play("back")
		angle = "back"
	elif enemy_angle >= 202.5 && enemy_angle < 247.5:
		play("back_left")
		angle = "back_left"
	elif enemy_angle >= 247.5 && enemy_angle < 292.5:
		play("left")
		angle = "left"
	elif enemy_angle >= 337.5 && enemy_angle > 360:
		play("front")
		angle = "front"
	elif enemy_angle >= 0 && enemy_angle > 22.5:
		play("front")
		angle = "front"

	ranged_attacking = false


func _on_vision_body_entered(body):
	if dead or ranged_active:
		return
	
	if body.has_method("handle_controls"):
		enemy.current_target = body
		ranged_active = true


	# Ranged attack animation, movement and direction
func ranged_attack():
	# if enemy is dead don't do anything
	if enemy.dead: return
	
	# enemy stops moving when ranged attacking
	enemy.move = false
	ranged_attacking = true
	
	# Look at target, get direction
	look_point_pos = lookpoint.global_position 
	look_point_pos = look_point_pos.normalized()
	look_point_dir = position - look_point_pos
	cam_pos = cam.global_transform.origin
	cam_dir = position - cam_pos
	angle_to_cam = rad_to_deg(atan2(cam_dir.x, cam_dir.z))
	angle_to_lookpoint = rad_to_deg(atan2(look_point_dir.x, look_point_dir.z))
	
	
	# Depending on enemy angle show coresponding animation.
	# degrees 0 - 22.5 = front
	# degrees 22.6 to 67.5 = front right
	# degrees  67.6 to 112.5
	# degrees 112.6 to 157.5
	# degrees 157.6 to 202.5
	# degrees 202.6 to 247.5
	# degrees 247.6 to 292.5
	# degrees 292.6 to 337.5
	# degrees 337.6 to 360
	
	
	
	##
	if enemy_angle < 0: 
		enemy_angle += 1

	if enemy_angle >= 292.6 && enemy_angle < 337.5:
		play("rattack_front_left")
		angle = "front_left"
	elif enemy_angle >= 22.6 && enemy_angle < 67.5:
		play("rattack_front_right")
		angle = "front_right"
	elif enemy_angle >= 67.6 && enemy_angle < 112.5:
		play("rattack_right")
		angle = "right"
	elif enemy_angle >= 112.6 && enemy_angle < 157.5:
		play("rattack_back_right")
		angle = "back_right"
	elif enemy_angle >= 157.6 && enemy_angle < 202.5:
		play("rattack_back")
		angle = "back"
	elif enemy_angle >= 202.6 && enemy_angle < 247.5:
		play("rattack_back_left")
		angle = "back_left"
	elif enemy_angle >= 247.6 && enemy_angle < 292.5:
		play("rattack_left")
		angle = "left"
	elif enemy_angle >= 337.6 && enemy_angle < 360:
		play("rattack_front")
		angle = "front"
	elif enemy_angle >= 0 && enemy_angle < 22.5:
		play("rattack_front")
		angle = "front"
	
	# Play ranged attack sound
	Audio.play("sounds/enemy/base/attack1.wav, sounds/enemy/base/attack2.wav, sounds/enemy/base/attack3.wav, sounds/enemy/base/attack4.wav")
	
	can_shoot = false

	# start ranged attack timer
	if dead: return
	await animation_finished
	timer.start()
	enemy.move = true
	chase_anim()
	enemy.fire_missile()
	

func _on_timer_timeout():
	can_shoot = true

	#If player enters this area monster will chase
func _on_chase_area_3d_body_entered(body):
	if dead: return
	
	# If in group player chase player. - Edit this to what ever group type 
	# You want the monster to chase
	if body.is_in_group("player"):
	# body that entered to become current target to chase and look at
		enemy.current_target = body
		
		enemy.move = true
		enemy.fresh = false
		chase = true
		idle = false
		ranged_active = false
		Audio.play("sounds/enemy/base/attack1.wav, sounds/enemy/base/attack2.wav, sounds/enemy/base/attack3.wav, sounds/enemy/base/attack4.wav")
		if Game_State.music_toggled_off: return
		if music_notplaying:
			var music = music_scene.instantiate()
			var scene_root = get_tree().root.get_children()[0]
			for song in get_tree().get_nodes_in_group("music"):
				song.queue_free()
			scene_root.add_child(music)
			music_notplaying = false
		

func _on_chase_area_3d_body_exited(body):
	# If in group player stop chasing player. - Edit this to what ever group type 
	# You want the monster to chase
	if body.is_in_group("player"):
		idle = true
		enemy.move = false
		chase = false

