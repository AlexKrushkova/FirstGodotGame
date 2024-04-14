extends Camera2D

@onready var top_left = $Limits/TopLeft
@onready var bottom_right = $Limits/BottomRight
@onready var buffer = 8 # The number of pixels to buffer so that the player cannot pass the camera's bounds


func _ready():
	limit_left = top_left.position.x
	limit_top = top_left.position.y
	limit_right = bottom_right.position.x
	limit_bottom = bottom_right.position.y
