extends Label

@export var ship: CharacterBody2D 

func _process(delta):

	if ship == null:
		return

	text = ""

	text += "Speed: %.1f\n" % ship.velocity_vector.length()

	var planet = GravityManager.get_closest_planet(ship.global_position)

	if planet:

		var altitude = ship.global_position.distance_to(planet.global_position) - planet.planet_radius

		text += "Altitude: %.1f\n" % altitude

	text += "State: %s" % ship.ShipState.keys()[ship.current_state]
