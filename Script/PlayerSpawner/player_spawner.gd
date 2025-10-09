# player_spawner.gd
extends Node3D

@export var player_scene: PackedScene

func _ready() -> void:
	# ⭐ SERVEUR : Attend les demandes de spawn des clients
	if multiplayer.is_server():
		print("PlayerSpawner ready on server side - waiting for clients")
		return
	
	# ⭐ CLIENT : Demande au serveur de spawn son joueur
	print("PlayerSpawner ready on client side")
	# Petit délai pour s'assurer que tout est synchronisé
	await get_tree().create_timer(0.1).timeout
	print("Requesting spawn from server...")
	var player_id = multiplayer.get_unique_id()
	spawn_player.rpc_id(1, player_id) # On envoie explicitement au serveur (ID 1)

# RPC : CLIENT demande → SERVEUR spawn le joueur
@rpc("any_peer", "call_remote", "reliable")
func spawn_player(player_id: int) -> void:
	# Seul le serveur traite ce RPC
	if not multiplayer.is_server():
		return
	
	print("Server: Spawning player ", player_id)
	
	var player = player_scene.instantiate()
	player.name = str(player_id)
	
	# IMPORTANT : L'autorité du joueur reste au serveur (1)
	# Car c'est le serveur qui calcule la physique
	# Les RPC @rpc("authority") viendront donc du serveur
	
	add_child(player, true)
	
	print("Player %d spawned successfully" % player_id)
