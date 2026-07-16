extends Label

@export var ship: CharacterBody2D 

func _process(_delta):
	if ship == null:
		return

	text = ""
	text += "Speed: %.1f\n" % ship.velocity_vector.length()

	var planet = GravityManager.get_closest_planet(ship.global_position)
	if planet:
		var distance = ship.global_position.distance_to(planet.global_position)
		var altitude = distance - planet.planet_radius
		text += "Altitude: %.1f\n" % altitude
		text += "Distance to Core: %.1f\n" % distance
		text += "Target Radius: %.1f\n" % planet.planet_radius

	text += "\n"
	text += "Mass: %.1f\n" % ship.ship_stats.total_mass
	text += "Thrust: %.1f\n" % ship.ship_stats.total_thrust
	text += "State: %s" % ship.ShipState.keys()[ship.current_state]
