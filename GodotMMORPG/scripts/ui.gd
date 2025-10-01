extends Control

@onready var game_scene = preload("res://GodotMMORPG/scenes/game.tscn") 

func _on_client_2_toggled(toggled_on: bool) -> void:
	NetworkHandler.start_client()
	print("client started")
	hide()

func _on_server_2_toggled(toggled_on: bool) -> void:
	NetworkHandler.start_server()
	print("server started")
	hide()
