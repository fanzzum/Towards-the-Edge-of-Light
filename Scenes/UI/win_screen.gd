extends Control

@onready var stats_label: Label = $MarginContainer/VBoxContainer/StatsLabel


func _on_return_button_pressed() -> void:
	# Go back to main menu
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
