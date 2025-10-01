extends CharacterBody3D

func _enter_tree() -> void:
	print(find_child("RollbackSynchronizer").state_properties)
	
func _rollback_tick(delta, tick, is_fresh):
	print("rollback_tick()")
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
