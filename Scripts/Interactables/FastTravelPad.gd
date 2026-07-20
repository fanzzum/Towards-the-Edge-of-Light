extends Area2D

var player_inside: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Explorer":
		player_inside = true
		print("Press 'Scan' or 'E' to Kick Off!")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Explorer":
		player_inside = false

func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("scan"):
		print("Launching into space from current planet...")
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")
