# player_input.gd
extends Node
class_name PlayerInput

var peer_id 

func _ready() -> void:
	await get_tree().process_frame
	peer_id = get_parent().name.to_int()
	set_multiplayer_authority(peer_id)
	# ⭐ SERVEUR : Jamais actif
	if multiplayer.is_server():
		print("SERVER : PLAYERINPUT : ", peer_id)
		set_process(false)
		return
	else:
		print("CLIENT : PLAYERINPUT : ", peer_id)
		set_process(true)

func _process(_delta: float) -> void:
	
	if multiplayer.is_server():
		return
	
	# Lire les inputs
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Envoyer au serveur (même si Vector2.ZERO pour arrêter le mouvement)
	get_parent().send_input_to_server.rpc_id(1, input)
