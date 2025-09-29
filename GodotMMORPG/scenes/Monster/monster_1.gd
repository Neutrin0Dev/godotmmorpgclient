extends CharacterBody3D
@export var speed: float = 2.0
@export var wander_radius: float = 5.0
@export var wander_timer: float = 3.0

var target_position: Vector3
var time_until_next_wander: float = 0.0


func _rollback_tick(delta, tick, is_fresh):
	time_until_next_wander -= delta
	
	if time_until_next_wander <= 0.0:		
		var random_angle = randf_range(0, TAU)
		target_position = global_position + Vector3(cos(random_angle), 0, sin(random_angle)) * wander_radius
		time_until_next_wander = wander_timer
		
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	global_position += velocity * delta
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
