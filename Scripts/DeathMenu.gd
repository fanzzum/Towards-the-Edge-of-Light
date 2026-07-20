extends CanvasLayer

func setup(duration: float, gathered: Dictionary):
	# Format time to 1 decimal place (e.g., "12.5s")
	$Panel/VBoxContainer/TimeLabel.text = "Flight Duration: %.1f seconds" % duration
	
	# Show exactly what was in the ship's cargo
	$Panel/VBoxContainer/CargoLabel.text = "Gathered: Ti:%d | Ld:%d | Ag:%d | Cu:%d" % [
		gathered.get("titanium", 0), 
		gathered.get("lead", 0), 
		gathered.get("silver", 0), 
		gathered.get("copper", 0)
	]

func _on_btn_planet_pressed():
	get_tree().change_scene_to_file("res://Scenes/Surface/SurfaceMap.tscn")
	queue_free()

func _on_btn_menu_pressed():
	# Replace with your actual main menu path
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn") 
	queue_free()
