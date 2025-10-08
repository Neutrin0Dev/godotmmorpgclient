# player.gd
extends CharacterBody3D

const SPEED := 5.0
const INTERPOLATION_SPEED := 10.0

var current_input := Vector2.ZERO

# Variables pour l'interpolation côté CLIENT
var server_position := Vector3.ZERO
var server_velocity := Vector3.ZERO

@export var camera : Camera3D
@export var player_input : PlayerInput

func _ready() -> void:
	await get_tree().process_frame

	# Initialiser l'interpolation
	server_position = global_position
	server_velocity = velocity

func _physics_process(delta: float) -> void:
	# SEULEMENT LE SERVEUR calcule la physique
	if not multiplayer.is_server():
		return
	
	# Gravité
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Appliquer l'input reçu du client
	var direction := Vector3(current_input.x, 0, current_input.y).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	# Broadcast position à TOUS les clients
	sync_position.rpc(global_position, velocity)

func _process(delta: float) -> void:
	# SEULEMENT LES CLIENTS font l'interpolation
	if multiplayer.is_server():
		return
	
	# Interpolation vers la position serveur
	global_position = global_position.lerp(server_position, INTERPOLATION_SPEED * delta)
	velocity = velocity.lerp(server_velocity, INTERPOLATION_SPEED * delta)

@rpc("any_peer","call_remote","unreliable")
func send_input_to_server(input):
	current_input = input

# RPC : SERVEUR envoie position → CLIENTS
@rpc("authority", "call_remote", "unreliable")
func sync_position(pos: Vector3, vel: Vector3) -> void:
	# Seuls les CLIENTS appliquent
	if multiplayer.is_server():
		return
	
	# Stocker la target pour l'interpolation
	server_position = pos
	server_velocity = vel
