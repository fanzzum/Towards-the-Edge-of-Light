extends Area2D
@onready var prompt_label = $PromptLabel
var player_in_range = false


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Explorer":
		player_in_range = true
		prompt_label.visible = true
		print("Press 'E' or 'Scan' to open Fabricator") # We will add a UI prompt later

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Explorer":
		player_in_range = false
		prompt_label.visible = false

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("scan"):
		var ui = $FabricatorUI
		ui.visible = !ui.visible # Toggles the menu on and off
