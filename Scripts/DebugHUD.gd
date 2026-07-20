extends Label

@export var ship: CharacterBody2D 

func _process(_delta):
	text = ""
	
	# --- 1. IF WE ARE IN SPACE (SHIP EXISTS) ---
	if ship != null:
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
		
		text += "Scan Progress: %.1f%%\n" % ((ship.scan_timer / ship.scan_duration) * 100.0)
		text += "Cargo: Ti:%d | Ld:%d | Ag:%d | Cu:%d\n" % [
			ship.cargo["titanium"], 
			ship.cargo["lead"], 
			ship.cargo["silver"], 
			ship.cargo["copper"]
		]
		
		# Scanning UI
		var scannable_planet = null
		for p in GravityManager.planets:
			if p.is_player_in_range and p.is_scannable:
				scannable_planet = p
				break
				
		if scannable_planet:
			text += "\n[ INFO ] Press F to scan"
		elif planet and (ship.global_position.distance_to(planet.global_position) - planet.planet_radius) < 1500:
			text += "\n[ INFO ] Get closer to a planet and press F to scan"

		# Landing UI
		var planet_to_land = GravityManager.can_land(ship.global_position)
		if planet_to_land and ship.current_state != 0: 
			var current_speed = ship.velocity_vector.length()
			if current_speed <= 350.0:
				text += "\n[ OK ] Press E to land on planet"
			else:
				text += "\n[ WARN ] Moving too fast to land! Speed: %.1f | Must be under: 350.0" % current_speed

	# --- 2. IF WE ARE ON THE SURFACE (EXPLORER) ---
	else:
		text += "--- SURFACE BASE ---\n"
		text += "Inventory:\n"
		text += "Titanium: %d | Lead: %d | Silver: %d | Copper: %d\n" % [
			GameState.titanium,
			GameState.lead,
			GameState.silver,
			GameState.copper
		]
		
		var total_time = GameState.total_play_time if "total_play_time" in GameState else 0.0
		text += "Total Play Time: %.1f s" % total_time
