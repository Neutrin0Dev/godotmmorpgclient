# player.gd
extends CharacterBody3D

const SPEED := 5.0
const INTERPOLATION_SPEED := 10.0

var current_input := Vector2.ZERO

# Variables pour l'interpolation côté CLIENT
var server_position := Vector3.ZERO

var peer_id : int

@export var camera : Camera3D
@export var player_input : PlayerInput

func _ready() -> void:
	# Récupérer le peer_id depuis le nom du nœud
	peer_id = name.to_int()
	
	print("Player %d ready (I am %d)" % [peer_id, multiplayer.get_unique_id()])
	
	# GESTION DE LA CAMÉRA : Seul le propriétaire active sa caméra
	if camera:
		var is_mine = (peer_id == multiplayer.get_unique_id())
		camera.current = is_mine
		if is_mine:
			print("Camera activated for my player %d" % peer_id)

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

# RPC : CLIENT envoie input → SERVEUR
@rpc("any_peer", "call_remote", "reliable")
func send_input_to_server(input: Vector2) -> void:
	# Vérification : seul le serveur reçoit ce RPC
	if not multiplayer.is_server():
		return
	
	# Vérifier que c'est le bon client qui envoie
	var sender_id = multiplayer.get_remote_sender_id()
	
	# Si l'input ne vient pas du propriétaire de ce joueur, on ignore
	if sender_id != peer_id:
		push_warning("Player %d received input from wrong sender %d" % [peer_id, sender_id])
		return
	
	current_input = input

# RPC : SERVEUR envoie position → CLIENTS
@rpc("authority", "call_remote", "unreliable")
func sync_position(pos: Vector3) -> void:
	# Seuls les CLIENTS reçoivent et appliquent
	if multiplayer.is_server():
		return
	
	server_position = pos
