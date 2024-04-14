extends CharacterBody2D

enum { MOVE, ROLL, ATTACK }

@export var max_speed: int = 80
@export var roll_speed: int = 120
@export var acceleration: int = 20

var state = MOVE
var roll_direction = Vector2.DOWN
var stats = PlayerStats

@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var hurtbox = $Hurtbox
@onready var player_hurt_sound = preload("res://Player/player_hurt_sound.tscn")
@onready var blink_animation_player = $BlinkAnimationPlayer


func _ready():
	randomize()
	stats.no_health.connect(queue_free)
	animation_tree.active = true


func _physics_process(_delta):
	match state:
		MOVE:
			move_state(_delta)
		ROLL:
			roll_state(_delta)
		ATTACK:
			attack_state(_delta)

	var camera = $"../../Camera2D"
	position.x = clamp(
		position.x, camera.limit_left + camera.buffer, camera.limit_right - camera.buffer
	)
	position.y = clamp(
		position.y, camera.limit_top + camera.buffer, camera.limit_bottom - camera.buffer
	)


func move_state(_delta):
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input_direction != Vector2.ZERO:
		roll_direction = input_direction
		animation_tree.set("parameters/Idle/blend_position", input_direction)
		animation_tree.set("parameters/Run/blend_position", input_direction)
		animation_tree.set("parameters/Attack/blend_position", input_direction)
		animation_tree.set("parameters/Roll/blend_position", input_direction)

		animation_state.travel("Run")

		velocity += input_direction * acceleration
		velocity = velocity.limit_length(max_speed)
	else:
		animation_state.travel("Idle")
		velocity = Vector2.ZERO

	disable_enemy_collision()
	move_and_slide()

	if Input.is_action_just_pressed("roll"):
		state = ROLL
	if Input.is_action_just_pressed("attack"):
		state = ATTACK


func roll_state(_delta):
	velocity = roll_direction * roll_speed
	animation_state.travel("Roll")
	enable_enemy_collision()
	move_and_slide()


func attack_state(_delta):
	velocity = Vector2.ZERO
	animation_state.travel("Attack")
	disable_enemy_collision()


func roll_animation_finished():
	velocity = Vector2.ZERO
	state = MOVE


func attack_animation_finished():
	state = MOVE


# Enables enemy collision (when the player is rolling).
# Allows the player to destroy grass by rolling into it.
func enable_enemy_collision():
	set_collision_layer_value(3, true)
	set_collision_mask_value(5, true)


func disable_enemy_collision():
	set_collision_layer_value(3, false)
	set_collision_mask_value(5, false)


func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()

	var instance = player_hurt_sound.instantiate()
	$"..".add_child(instance)


func _on_hurtbox_invincibility_started():
	blink_animation_player.play("blink")


func _on_hurtbox_invincibility_ended():
	blink_animation_player.stop()
