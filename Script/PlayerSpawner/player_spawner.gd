# player_spawner.gd
extends Node3D

@export var player_scene: PackedScene

func _ready() -> void:
	
	# ⭐ SERVEUR DÉDIÉ : Pas de joueur pour le host
	if multiplayer.is_server():
		print("PlayerSpawner ready on server side - waiting for clients")
		return
	
	# ⭐ CLIENT : On attend un peu que tout soit bien chargé, puis on demande le spawn
	print("PlayerSpawner ready on client side")
	# Petit délai pour s'assurer que tout est synchronisé
	await get_tree().create_timer(0.1).timeout
	print("Call the spawning RPC to the server")
	var player_id = multiplayer.get_unique_id()
	spawn_player.rpc_id(1, player_id) # On envoie explicitement au serveur (ID 1)

@rpc("any_peer","call_remote","reliable")
func spawn_player(player_id):
	print("Server: Spawning player ", player_id)
	var player = player_scene.instantiate()
	player.name = str(player_id)
	add_child(player, true)
	
	# ⭐ L'autorité du joueur est donnée à son propriétaire
	player.set_multiplayer_authority(player_id, true)
	
	var input = player.find_child("PlayerInput")
	if input:
		input.set_multiplayer_authority(player_id)
		
	var camera = player.find_child("Camera3D")
	if camera:
		print("camera detecté")
		camera.set_multiplayer_authority(player_id)
