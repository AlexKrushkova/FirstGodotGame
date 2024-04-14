extends Area2D

signal invincibility_started
signal invincibility_ended

const HIT_EFFECT = preload("res://Effects/hit_effect.tscn")

var invincible: bool = false:
	set(value):
		invincible = value
		if invincible == true:
			emit_signal("invincibility_started")
		else:
			emit_signal("invincibility_ended")

@onready var timer = $Timer


func start_invincibility(duration: int):
	self.invincible = true
	timer.start(duration)


func create_hit_effect():
	var effect = HIT_EFFECT.instantiate()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position


func _on_timer_timeout():
	self.invincible = false


func _on_invincibility_started():
	set_deferred("monitoring", false)


func _on_invincibility_ended():
	set_deferred("monitoring", true)
