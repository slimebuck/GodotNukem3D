extends Area3D

##damage of fire after explosion, happens every tick of Fire_Timer
@export var fire_damage : int = 2
##Has fire fell to ground? if so take away gravity
@export var fire_landed : bool = false
##Speed that fire falls to the ground
@export var speed : float = 5.0

@onready var fire_area = $"."


func _ready():
	
		# Play burning sound
	$Fire_Burn_Sound.play()
		# Play fire animation
	$Animated_Fire.play("Fire")


func _process(delta):
		#fire landed checks if fire is on the ground. if so, make it go down
	if fire_landed == false:
		translate(Vector3(0, -speed * delta, 0))


func _on_body_entered(body):
	
	# When body enters fire, get burned!
	if body.has_method("get_hit"):
		body.get_hit(fire_damage)
		
			# Start timer to control how quickly fire damage ticks
		body.fire_timer.start()
		return
		
		# if fire has landed on the ground, stop making it go down
	if fire_landed == false:
		fire_landed = true
		fire_area.fire_landed = true


func _on_body_exited(body):
	if body.has_method("get_hit"):
		body.fire_timer.stop()
	

