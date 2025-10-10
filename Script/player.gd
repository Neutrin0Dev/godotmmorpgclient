# player.gd
extends CharacterBody3D

var SPEED := 5.0
const INTERPOLATION_SPEED := 1.0

var current_input := Vector2.ZERO

# Variables pour l'interpolation côté CLIENT
var player_position := Vector3.ZERO
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
	if multiplayer.is_server():
		Engine.physics_ticks_per_second = 1
	else:
		Engine.physics_ticks_per_second = 60



func _physics_process(delta: float) -> void:
	# SEULEMENT LE SERVEUR calcule la physique a appliqué au joueur
	if not multiplayer.is_server():
		# Gravité
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Appliquer l'input reçu du client
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		move_and_slide()
		
		send_player_position.rpc(global_position)
	else:
		# Gravité
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Appliquer l'input reçu du client
		var direction := (transform.basis * Vector3(current_input.x, 0, current_input.y)).normalized()
		
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		move_and_slide()
		
		# Broadcast position à TOUS les clients
		if player_position != Vector3.ZERO:
			var distance := global_position.distance_to(player_position)
			if distance > 5:
				print("joueur trop loin")	
				sync_position.rpc(global_position)

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

# RPC : CLIENT envoie position → SERVEUR
@rpc("any_peer","call_remote","reliable")
func send_player_position(pos: Vector3) -> void:
	if not multiplayer.is_server():
		return
	var sender_id = multiplayer.get_remote_sender_id()
	
	# Si l'input ne vient pas du propriétaire de ce joueur, on ignore
	if sender_id != peer_id:
		push_warning("Player %d received input from wrong sender %d" % [peer_id, sender_id])
		return
	player_position = pos

# RPC : SERVEUR envoie position → CLIENTS
@rpc("authority", "call_remote", "unreliable_ordered")
func sync_position(pos: Vector3) -> void:
	# Seuls les CLIENTS reçoivent et appliquent
	if multiplayer.is_server():
		return
	
	global_position = pos
