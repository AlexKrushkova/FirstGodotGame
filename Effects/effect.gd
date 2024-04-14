extends AnimatedSprite2D


func _ready():
	self.animation_finished.connect(_on_animation_finished)
	play()


func _on_animation_finished():
	queue_free()
