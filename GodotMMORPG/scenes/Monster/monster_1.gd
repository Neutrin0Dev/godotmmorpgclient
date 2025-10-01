extends CharacterBody3D
@export var speed = 1.0
@export var input: MonsterInput

func _rollback_tick(delta, tick, is_fresh):
	# Add the gravity.
	_force_update_is_on_floor()
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir = input.movement
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# Apply movement
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor

func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector3.ZERO
	move_and_slide()
	velocity = old_velocity
