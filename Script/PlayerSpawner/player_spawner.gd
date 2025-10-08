# player_spawner.gd
extends Node3D

@export var player_scene: PackedScene

func _ready() -> void:
	await get_tree().process_frame
	# ⭐ SERVEUR DÉDIÉ : Pas de joueur pour le host
	if not multiplayer.is_server():
		print("PlayerSpawner ready on client side")
		print("Call the spawning RPC to the server")
		var player_id = multiplayer.get_unique_id()
		player_is_ready(player_id)
		return

func player_is_ready(player_id):
	if NetworkHandler.player_list.has(player_id):
		print("Le ", player_id, " est présent dans la playerlist")
		spawn_player.rpc_id(1,player_id)
	
@rpc("any_peer","call_remote","reliable")
func spawn_player(player_id):
	var player = player_scene.instantiate()
	player.name = str(player_id)
	add_child(player, true)
