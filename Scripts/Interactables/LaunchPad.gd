extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Explorer":
		print("Kicking off back to space!")
		# Replace this string with the exact path to your main space/flight scene
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")
