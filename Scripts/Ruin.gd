extends Area2D

@export var blueprint_a: ShipPart
@export var blueprint_b: ShipPart

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Explorer": 
		body.active_ruin = self

func _on_body_exited(body):
	if body.name == "Explorer" and body.active_ruin == self: 
		body.active_ruin = null
