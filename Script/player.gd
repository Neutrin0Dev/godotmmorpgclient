# player.gd
extends CharacterBody3D

const SPEED := 5.0
const INTERPOLATION_SPEED := 10.0

var current_input := Vector2.ZERO

# Variables pour l'interpolation côté CLIENT
var server_position := Vector3.ZERO

var peer_id

@export var camera : Camera3D
@export var player_input : PlayerInput

func _ready() -> void:
	# Récupérer le peer_id depuis le nom du nœud
	peer_id = name.to_int()
	
	# ⭐ GESTION DE LA CAMÉRA
	if camera:
		# Seul le propriétaire du joueur active sa caméra
		if peer_id == multiplayer.get_unique_id():
			camera.current = true
			print("Camera activated for local player: ", peer_id)
		else:
			#camera.current = false
			return
	if player_input:
		if peer_id == multiplayer.get_unique_id():
			return
		else:
			player_input.set_multiplayer_authority(peer_id)
	# Sur le serveur, désactiver toutes les caméras (serveur dédié)
	#if multiplayer.is_server() and camera:
		#camera.current = false

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
	sync_position.rpc(global_position)

func _process(delta: float) -> void:
	# SEULEMENT LES CLIENTS font l'interpolation
	if multiplayer.is_server():
		return
	
	# Interpolation vers la position serveur
	global_position = global_position.lerp(server_position, INTERPOLATION_SPEED * delta)

@rpc("any_peer", "call_remote", "unreliable")
func send_input_to_server(input: Vector2) -> void:
	# Vérification : on vérifie que c'est le bon client qui envoie
	var sender_id = multiplayer.get_remote_sender_id()
	
	# Si l'input ne vient pas du propriétaire de ce joueur, on ignore
	if sender_id != peer_id:
		return
	
	current_input = input

# RPC : SERVEUR envoie position → CLIENTS
@rpc("authority", "call_local", "unreliable")
func sync_position(pos: Vector3) -> void:
	# Seuls les CLIENTS appliquent
	if multiplayer.is_server():
		return

	server_position = pos
