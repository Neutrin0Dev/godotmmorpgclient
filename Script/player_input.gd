# player_input.gd
extends Node
class_name PlayerInput

func _ready() -> void:
	await get_tree().process_frame
	# ⭐ SERVEUR : Jamais actif
	if multiplayer.is_server():
		set_process(false)
		return
	else:
		set_process(true)

func _process(_delta: float) -> void:
	
	if multiplayer.is_server():
		return
	
	# Lire les inputs
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Envoyer au serveur (même si Vector2.ZERO pour arrêter le mouvement)
	get_parent().send_input_to_server.rpc_id(1, input)
