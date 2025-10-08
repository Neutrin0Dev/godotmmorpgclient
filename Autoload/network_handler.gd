# network_handler.gd
#AUTOLOAD
extends Node

# ═════════════════════════════════════════
# CONSTANTS
# ═════════════════════════════════════════

const PORT := 42069
const IP_ADDRESS := "localhost"
const MAX_CLIENTS := 10

# ═════════════════════════════════════════
# VARIABLES
# ═════════════════════════════════════════

var player_list : Dictionary = {}

func _ready() -> void:
	#only on client :
	multiplayer.connected_to_server.connect(_on_client_connected)
	multiplayer.connection_failed.connect(_on_client_connexion_fail)
	multiplayer.server_disconnected.connect(_on_client_disconnect)
	
	#Both client and server
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func start_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT,MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	# Le serveur charge la scène immédiatement
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func start_client():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _on_client_connected():
	var peer_id = multiplayer.get_unique_id()
	if player_list.has(peer_id):
		return
	else:
		
		print("Client is connected to the server")
	
		# Le client charge la scène quand il se connecte
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_client_connexion_fail():
	print("Client failed to connect")

func _on_client_disconnect():
	print("Client disconnected")

func _on_peer_connected(peer_id):
	player_list[peer_id] = peer_id
	print(peer_id, " : is connected to the server.")
	
func _on_peer_disconnected(peer_id):
	print(peer_id," : is disconnected.")
	player_list.erase(peer_id)
