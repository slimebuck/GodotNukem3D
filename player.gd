extends CharacterBody3D

var fire_damage : int = 2
var fire_time : bool = true

	#onready vars to connect nodes for code use
@onready var player = $"."
@onready var animated_sprite_2d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var raycast = $head/Camera3D/RayCast
@onready var gunsound = $gunsound
@onready var camera_3d = $head/Camera3D
@onready var sound_footsteps = $SoundFootsteps
@onready var deathscreen = $CanvasLayer/deathscreen
@onready var gun_flash = $head/Camera3D/gun_flash
@onready var gun_flash2 = $head/Camera3D/gun_flash2
@onready var flash_timer = $Flash_Timer
@onready var fire_timer = $Fire_Timer


## Players base speed
@export var SPEED : float = 10.0
## layers current speed
@export var SPEED_current : float = 10.0

## Players base jump strength
@export var jump_strength : float = 8
## Players current jump strength
@export var jump_strength_current : float = 8


## If the player can shoot
@export var can_shoot : bool = true

## Players MAXimum health number
@export var player_MAX_heath :int = 10000

## Player's current health
@export var player_health :int = 10000

## Player is dead
@export var dead :bool = false

## Players mouse sensitivity as a float
@export var mouse_sensitivity : float = 800

## Players gamepad sensitivity as a float
@export var gamepad_sensitivity : float = 0.075
##Player gravity, how fast they fall downwards
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	# mouse control vars
var mouse_captured : bool = true
var movement_velocity: Vector3
var rotation_target: Vector3
var input_mouse: Vector2


	# jump control cars
var previously_floored : bool = false
var jump_single : bool = true
var jump_double : bool = true


	# speed control vars
var normal_speed : bool = true
var normal_speed2 : bool = true
var normal_speed3 = true
var fast_mode : bool = false
var hyper_mode : bool = false 
var forward_held : bool = false

	# UI vars
var container_offset = Vector3(1.2, -1.1, -2.75)

	# Damage Vars
@export var current_damage : int
const handgun_damage : int = 20
const machinegun_damage :int = 5
const sniper_damage : int = 100

var blood_decal = preload("res://blood_decal.tscn")
var blood_particles = preload("res://blood_particles.tscn")

var song1 = preload("res://music_scene_1.tscn")

var level : int = 1


func _ready():
	

	# Capture mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Hide any gun flashes
	gun_flash.hide()
	gun_flash2.hide()
	# Start flash timer, mount of seconds light is on when gun fires
	flash_timer.start()
	
	# Set current player damage to the starting weappon
	current_damage = handgun_damage
	
	music_select()
	

func _input(event):
	# If player is dead do not allow movement
	if dead:
		return

	# if mouse is captured and moving translate mouse movement to character rotation
	if event is InputEventMouseMotion and mouse_captured:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity

func handle_controls(_delta):

	# Movement
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * SPEED_current
	
	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		
		
		if jump_single or jump_double:
			Audio.play("sounds/player/jump_a.ogg, sounds/player/jump_b.ogg, sounds/player/jump_c.ogg, sounds/player/jump1.wav")
		
		if jump_double:
			gravity = -jump_strength_current
			jump_double = false
			
		if(jump_single): action_jump()


func handle_gravity(delta):
	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0


	# Jump function

func action_jump():
	
	gravity = -jump_strength_current
	SPEED_current = SPEED_current + 1
	
	jump_single = false;
	jump_double = true;
	

	# This system allows player to travel faster every jump they make.
	# This is a slow build up and emulates bnunny hopping.
	if hyper_mode:
		jump_strength_current=jump_strength_current + 0.2
	if fast_mode:
		hyper_mode = true
		fast_mode = false
		SPEED_current = SPEED_current + 6
		jump_strength_current=jump_strength_current + 1
			
	if normal_speed:
		fast_mode = true
		normal_speed = false
		SPEED_current = SPEED_current + 4
		jump_strength_current=jump_strength_current + 0.5


func _process(_delta):
	# enable exit and restart buttons
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		_on_button_button_up()
	if Input.is_action_just_pressed("toggle_music"):
		if Game_State.music_toggled_off: 
			Game_State.music_toggled_off = false
			return
		for song in get_tree().get_nodes_in_group("music"):
			song.queue_free()
			Game_State.music_toggled_off = true
			

	# If player is dead do not allow any other actions
	if dead:
		return

	# Connect button presses to respective actions
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	if Input.is_action_just_pressed("move_forward"):
		forward_held = true
		
	if Input.is_action_just_released("move_forward"):
		forward_held = false

		# Fake bunny hopping system returns player to base speed if they press 
		# any button other than forward, or rleease forward
	
	if Input.is_action_just_released("move_forward") and is_on_floor():
		normalspeed()
		
	if Input.is_action_just_pressed("move_left"):
		normalspeed()
		
	if Input.is_action_just_pressed("move_right"):
		normalspeed()
		
	if Input.is_action_just_pressed("move_backwards"):
		normalspeed()


func _physics_process(delta):
		#Do not do anything if player is dead
	if dead:
		return
	
	# Handle functions
	
	handle_controls(delta)
	handle_gravity(delta)
	
	# Movement
	var applied_velocity: Vector3
	
	movement_velocity = transform.basis * movement_velocity # Move forward
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	
	camera_3d.rotation.z = lerp_angle(camera_3d.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
	
	camera_3d.rotation.x = lerp_angle(camera_3d.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	


	# Movement sound
	
	# Turn sound off because it auto plays
	sound_footsteps.stream_paused = true
	
	# If player is on the ground then play walking sound
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false
	
	# Landing after jump or falling
	
	camera_3d.position.y = lerp(camera_3d.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored: # Landed
		Audio.play("sounds/player/step2.wav")
		camera_3d.position.y = -0.1
	
	previously_floored = is_on_floor()
	
	# Falling/respawning
	
	if position.y < -10:
		_on_button_button_up()

	# Fake Bunny Hop system function to return player to base speed
func normalspeed():
	normal_speed = true
	fast_mode = false
	hyper_mode = false
	jump_strength_current = jump_strength
	SPEED_current = SPEED

	#Attack function
func shoot():
	if !can_shoot:
		return
	can_shoot = false
	gun_flash.show()
	gun_flash2.show()
	animated_sprite_2d.play("shoot")
	gunsound.play()
	

	if raycast.is_colliding() and raycast.get_collider().has_method("get_hit"):
		raycast.get_collider().get_hit(current_damage)


	# When player takes damage
func get_hit(damage):
		#If player is dead dont want to do anything more so return
	if dead:
		return
		
	if damage == 2:
		player_health -= damage
		fire_time = false
	else:
		player_health -= damage
		#Remove health from player current health variable
	
		#Play pain sound for player, pick between a few sounds
	Audio.play("sounds/player/pain50_1.wav, sounds/player/lava1.wav, sounds/player/death4.wav, sounds/player/burn1.wav, sounds/player/burn2.wav")
	spawn_blood()
	
		#If player is dead do kill function
	if player_health <= 0:
		kill()


	# On players death
func kill():
		#Prevent action if deaf
	if dead:
		return
		#Play death sound
	Audio.play("sounds/player/pain50_1.wav, sounds/player/lava1.wav, sounds/player/death4.wav, sounds/player/burn1.wav, sounds/player/burn2.wav")
	deathscreen.show()
	dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


	#Light on end of gun when firing turn of when timer timesout function
func _on_flash_timer_timeout():
	gun_flash.hide()
	gun_flash2.hide()


	# When shooting animation is done allows player to shoot again
func _on_animated_sprite_2d_animation_finished():
	can_shoot = true

	#Despawn group types when restarting level
func _on_button_button_up():
	for fire in get_tree().get_nodes_in_group("fire"):
		fire.queue_free()
	for barrels in get_tree().get_nodes_in_group("barrel"):
		barrels.queue_free()
	for missile in get_tree().get_nodes_in_group("missile"):
		missile.queue_free()
	for decal in get_tree().get_nodes_in_group("decals"):
		decal.queue_free()
	for song in get_tree().get_nodes_in_group("music"):
		song.queue_free()
	for explosion in get_tree().get_nodes_in_group("explosion"):
		explosion.queue_free()
	get_tree().reload_current_scene()


	#Spawn blood when hit function.
	# Controls a decal on the ground, and blood particle effects
func spawn_blood():
	var blood_splat = blood_decal.instantiate()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(blood_splat)
	
	blood_splat.transform = global_transform
	
	var blood_spray = blood_particles.instantiate()
	add_child(blood_spray)


	# If player standing in a fire this controls fire damage tick rate
func _on_fire_timer_timeout():
	get_hit(2)
	
	
func music_select():
	if Game_State.music_toggled_off: return
	if level == 1:
			var songtoplay = song1.instantiate()
			var scene_root = get_tree().root.get_children()[0]
			scene_root.add_child(songtoplay)

