extends Control

@export var game_scene : PackedScene  

func _on_client_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)
	NetworkHandler.start_client()

func _on_server_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)
	NetworkHandler.start_server()

	
