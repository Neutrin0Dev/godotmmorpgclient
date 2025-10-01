extends CharacterBody3D

@export var speed: float = 2.0
@export var wander_radius: float 
@export var wander_timer: float 
@onready var rng = RandomNumberGenerator.new()
var gravity = ProjectSettings.get_setting(&"physics/3d/default_gravity")
var target_position: Vector3
var time_until_next_wander: float = 0.0

func _ready() -> void:
	wander_timer = rng.randf_range(5.0,10.0)
	wander_radius = wander_timer

func _rollback_tick(delta, tick, is_fresh):
	if is_multiplayer_authority():
		prints(multiplayer.get_unique_id(), multiplayer.is_server(), global_position)
	_force_update_is_on_floor()
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	time_until_next_wander -= delta
	
	if time_until_next_wander <= 0.0:		
		var random_angle = rng.randf_range(0, TAU)
		target_position = global_position + Vector3(cos(random_angle), 0, sin(random_angle)) * wander_radius
		time_until_next_wander = wander_timer
		
	var direction = (target_position - global_position).normalized()
	velocity.x = move_toward(velocity.x, direction.x, speed)
	velocity.z = move_toward(velocity.z, direction.z, speed)
	
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor

func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector3.ZERO
	move_and_slide()
	velocity = old_velocity
