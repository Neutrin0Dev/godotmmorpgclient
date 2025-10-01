extends Control

func _on_client_pressed() -> void:
	NetworkHandler.start_client()
	print("client started")
	hide()

func _on_server_pressed() -> void:
	NetworkHandler.start_server()
	print("server started")
	hide()
