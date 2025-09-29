extends CharacterBody3D

@export var speed = 4.0
const JUMP_VELOCITY = 4.5
@export var input: PlayerInput
@onready var rollback_synchronizer = $RollbackSynchronizer

func _ready() -> void:
	if name == "Player #1":
		self.hide()

func _rollback_tick(delta, tick, is_fresh):
	if is_zero_approx(input.confidence):
		# Can't predict, not enough confidence in input
		rollback_synchronizer.ignore_prediction(self)
		return
			
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif input.input_jump > 0 :
		velocity.y = JUMP_VELOCITY * input.input_jump
			
	var input_dir = input.movement
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
