# network_handler.gd
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

func start_client():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _on_client_connected():
	print("Client is connected")

func _on_client_connexion_fail():
	print("Client failed to connect")

func _on_client_disconnect():
	print("Client disconnected")

func _on_peer_connected(peer_id):
	print(peer_id, " : is connected to the server.")
	print(peer_id, " : start the game scene")
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
func _on_peer_disconnected(peer_id):
	print(peer_id," : is disconnected.")
