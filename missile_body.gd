extends StaticBody3D
@onready var missile = $".."

func _ready():
	pass

func _process(_delta):
	pass

func get_hit(_damage):
	$"../..".explode()
