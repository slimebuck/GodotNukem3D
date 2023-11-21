extends Sprite_Rotation


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_rot_readyup()

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	idle_to_chase()


