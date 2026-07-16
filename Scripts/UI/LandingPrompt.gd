extends Label

@onready var ship: CharacterBody2D = $"../../Ship"

func _process(_delta):
	if ship == null:
		hide()
		return
		
	if ship.current_state != ship.ShipState.FLIGHT:
		hide()
		return
		
	var planet = GravityManager.can_land(ship.global_position)
	if planet != null:
		show()
	else:
		hide()
