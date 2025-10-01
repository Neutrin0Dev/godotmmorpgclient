extends CharacterBody3D

@onready var rollback_synchronizer = $RollbackSynchronizer

func _ready() -> void:
	print(multiplayer.get_peers())

func _rollback_tick(delta, tick, is_fresh):
	print("rollback_tick()")
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
