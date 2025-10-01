extends Control

@onready var game_scene = preload("res://GodotMMORPG/scenes/game.tscn") 

func _on_client_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)
	print("client change_scene")
	NetworkHandler.start_client()
	print("client started")
	
func _on_server_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)
	print("server change_scene")
	NetworkHandler.start_server()
	print("server started")
	
	
