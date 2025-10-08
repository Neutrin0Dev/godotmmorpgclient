# player_spawner.gd
extends Node3D

@export var player_scene: PackedScene

var spawn_position := Vector3(0, 0, 0)

func _ready() -> void:
	
	# ⭐ SERVEUR DÉDIÉ : Pas de joueur pour le host
	if not multiplayer.is_server():
		print("PlayerSpawner ready on client side")
		print("Call the spawning RPC to the server")
		var player_id = multiplayer.get_unique_id()
		spawn_player.rpc(player_id)
		return
	else:
		spawn_player(1)

@rpc("any_peer","call_remote","reliable")
func spawn_player(player_id):
	var player = player_scene.instantiate()
	player.name = str(player_id)
	call_deferred("add_child",player)
