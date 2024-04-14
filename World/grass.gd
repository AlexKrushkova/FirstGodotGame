extends Node2D

@onready var grass_effect = preload("res://Effects/grass_effect.tscn")


func _on_hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()


func _on_hurtbox_body_entered(_body):
	create_grass_effect()
	queue_free()


func create_grass_effect():
	var instance = grass_effect.instantiate()
	$"..".add_child(instance)
	instance.global_position = global_position
