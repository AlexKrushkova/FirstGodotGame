extends CharacterBody2D

enum { IDLE, WANDER, CHASE }

const KNOCKBACK_SPEED: int = 175

@export var acceleration: int = 300
@export var max_speed: int = 50

var state = CHASE

@onready var stats = $Stats
@onready var animated_sprite = $AnimatedSprite2D
@onready var player_detection_zone = $PlayerDetectionZone
@onready var enemy_death_effect = preload("res://Effects/enemy_death_effect.tscn")
@onready var hurtbox = $Hurtbox
@onready var soft_collision = $SoftCollision
@onready var wander_controller = $WanderController
@onready var animation_player = $AnimationPlayer


func _physics_process(delta):
	match state:
		IDLE:
			velocity = Vector2.ZERO
			seek_player()

			if wander_controller.get_time_left() == 0:
				start_wandering()
		WANDER:
			seek_player()

			if (
				global_position.distance_to(wander_controller.target_position)
				<= (max_speed * delta)
			):
				start_wandering()

			accelerate_to(wander_controller.target_position, delta)
		CHASE:
			var player = player_detection_zone.player

			if player_detection_zone.can_see_player():
				accelerate_to(player.global_position, delta)
			else:
				state = IDLE

	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * 400

	move_and_slide()


func accelerate_to(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	animated_sprite.flip_h = velocity.x < 0


func start_wandering():
	state = get_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(randf_range(1, 3))


func seek_player():
	if player_detection_zone.can_see_player():
		state = CHASE


func get_random_state(state_list: Array):
	state_list.shuffle()
	return state_list.pop_front()


func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	var direction = (position - area.owner.position).normalized()
	velocity = direction * KNOCKBACK_SPEED
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)


func _on_stats_no_health():
	queue_free()
	var instance = enemy_death_effect.instantiate()
	$"..".add_child(instance)
	instance.global_position = global_position


func _on_hurtbox_invincibility_started():
	animation_player.play("blink")


func _on_hurtbox_invincibility_ended():
	animation_player.stop()
