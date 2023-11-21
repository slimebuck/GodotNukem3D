extends Node3D

		#Timer for how long blood sprays
@onready var timer = $Timer

		#get gpuparticle ready
@onready var gpuparticle = $gpuparticle

func _ready():
		#Get Timer ready and get gpuparticle emitting
	timer.start()
	gpuparticle.emitting = true
	
func _process(_delta):
	pass

		#Stop emitting blood after timer timesout
func _on_timer_timeout():
	gpuparticle.emitting = false
