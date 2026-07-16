extends Node2D

@onready var home_planet: Planet = $HomePlanet
@onready var ship: CharacterBody2D = $Ship

func _ready():
	# 1. Force the planet to show its surface diorama
	GravityManager.exclusive_gravity_planet = home_planet
	home_planet.is_landing_target = true
	
	# 2. Force the ship into the landed state immediately
	ship.current_state = ship.ShipState.LANDED
	ship.spawn_explorer()
	
	# 3. Snap the camera to the zoomed-in landing mode
	get_tree().call_group("camera", "set_landing_mode", true)
