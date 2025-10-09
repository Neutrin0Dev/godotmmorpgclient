# player_input.gd
extends Node
class_name PlayerInput

var is_ready_to_send := false

func _ready() -> void:
	# Attendre que tout soit bien initialisé
	await get_tree().process_frame
	
	#SERVEUR : Jamais actif
	if multiplayer.is_server():
		set_process(false)
		return
	
	# Attendre que le parent (player) soit bien setup
	await get_tree().create_timer(0.2).timeout
	
	# Vérifier qu'on est bien sur NOTRE joueur
	var parent_peer_id = get_parent().name.to_int()
	var our_peer_id = multiplayer.get_unique_id()
	
	if parent_peer_id != our_peer_id:
		# Ce n'est pas notre joueur, on désactive
		set_process(false)
		return

	is_ready_to_send = true
	set_process(true)

func _process(_delta: float) -> void:
	# Double vérification
	if multiplayer.is_server() or not is_ready_to_send:
		return
	
	# Lire les inputs
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Envoyer au serveur (même si Vector2.ZERO pour arrêter le mouvement)
	get_parent().send_input_to_server.rpc_id(1, input)
