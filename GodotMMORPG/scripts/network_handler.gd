#network_handler.gd
extends Node

const IP_ADRESS: String = "localhost"
const PORT: int = 42069
#const IP_ADRESS: String = "16.ip.gl.ply.gg"
#const PORT: int = 3109
const MAX_CLIENTS: int = 10

var peer: ENetMultiplayerPeer
	
func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADRESS, PORT)
	multiplayer.multiplayer_peer = peer
	
func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT,MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	
