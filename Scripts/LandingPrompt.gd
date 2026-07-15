extends Label

@export var ship : CharacterBody2D

func _process(delta):
	visible = GravityManager.can_land(ship.global_position) != null
