extends Control

func _on_play_button_pressed() -> void:
	# Reset global planet position
	GameState.current_planet_position = Vector2.ZERO
	
	# Load the Intro Story screen first!
	get_tree().change_scene_to_file("res://Scenes/IntroScreen.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
