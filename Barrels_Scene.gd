extends Node3D

##Barrel velocity
@export var velocity = Vector3.ZERO

var barrel_landed : bool = false

##Barrel Gravity time to control how far it gets launched from monster
@export var grav_timer : bool = false

@onready var gTimer = $Timer
@onready var kill_timer = $Kill_Timer
@onready var barrel_body = $Barrel_RigidBody3D


func _ready():
	gTimer.start()
	kill_timer.start()
	barrel_body.projectile = true
	
func _physics_process(delta):
	if grav_timer == true:
		return
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta
	



func _on_timer_timeout():
	grav_timer = true
	velocity = Vector3.ZERO
	#look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity


func _on_kill_timer_timeout():
	if barrel_body.barrel_alive:
		barrel_body.get_hit(20)
	queue_free()

