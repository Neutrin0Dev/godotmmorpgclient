extends CharacterBody3D

# --- Paramètres de mouvement ---
const SPEED := 2.0
const STOP_DISTANCE := 1.0
const MIN_WAIT_TIME := 5.0
const MAX_WAIT_TIME := 12.0
const INTERPOLATION_SPEED := 0.1 

# --- Variables d'état (serveur) ---
var radius: float
var radius_center: Vector3
var target_position: Vector3
var is_waiting: bool = false
var wait_timer: float = 0.0

# --- Variables pour l'interpolation (client) ---
var server_position: Vector3 = Vector3.ZERO

# --------------------------------------------------------------------
func _ready() -> void:
	if multiplayer.is_server():
		sync_position.rpc(global_position)
		print("Radius : ",radius, " Radius center : ", radius_center)
		Engine.physics_ticks_per_second = 1
		_find_random_target()
# --------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_handle_server_movement(delta)

# --------------------------------------------------------------------
func _handle_server_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			is_waiting = false
			_find_random_target()
		return

	# Déplacement vers la cible
	var direction := (target_position - global_position).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	var distance_to_target := global_position.distance_to(target_position)

	if distance_to_target <= STOP_DISTANCE:
		move_and_slide()
		is_waiting = true
		wait_timer = randf_range(MIN_WAIT_TIME, MAX_WAIT_TIME)
		return


	move_and_slide()

	sync_position.rpc(global_position)

# --------------------------------------------------------------------
func _process(delta: float) -> void:
	# SEULEMENT LES CLIENTS font l'interpolation
	if not multiplayer.is_server():
		global_position = global_position.lerp(server_position, INTERPOLATION_SPEED * delta)

# --------------------------------------------------------------------
func _find_random_target() -> void:
	var random_angle := randf_range(0, TAU)
	var random_radius := randf_range(0, radius)
	target_position = radius_center + Vector3(cos(random_angle), 0, sin(random_angle)) * random_radius
	
# --------------------------------------------------------------------
# RPC : SERVEUR envoie position → CLIENTS 
@rpc("any_peer", "call_remote", "unreliable")
func sync_position(pos: Vector3) -> void:
	if multiplayer.is_server():
		return  
	server_position = pos  
