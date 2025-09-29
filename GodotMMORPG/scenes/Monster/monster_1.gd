extends Node3D
@export var speed: float = 2.0
@export var wander_radius: float = 5.0
@export var wander_timer: float = 3.0

var velocity: Vector3 = Vector3.ZERO
var target_position: Vector3
var time_until_next_wander: float = 0.0

func _ready():
	print(get_multiplayer_authority())

func _rollback_tick(delta, tick, is_fresh):
	if not multiplayer.is_server():
		return  

	time_until_next_wander -= delta
	
	if time_until_next_wander <= 0.0:		
		var random_angle = randf_range(0, TAU)
		target_position = global_position + Vector3(cos(random_angle), 0, sin(random_angle)) * wander_radius
		time_until_next_wander = wander_timer
		
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	global_position += velocity * delta
