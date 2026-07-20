extends Node

var planets: Array = []
var exclusive_gravity_planet = null

func register_planet(planet):
	if !planets.has(planet):
		planets.append(planet)

func unregister_planet(planet):
	planets.erase(planet)

func calculate_gravity(position: Vector2) -> Vector2:
	var total_force := Vector2.ZERO

	for planet in planets:
		if exclusive_gravity_planet != null and planet != exclusive_gravity_planet:
			continue

		# Skip objects with 0 or missing gravity radius/strength
		var radius = planet.get("gravity_radius")
		var strength = planet.get("gravity_strength")
		if radius == null or strength == null or radius <= 0.0 or strength <= 0.0:
			continue

		var direction = planet.global_position - position
		var distance = direction.length()

		if distance < 10 or distance > radius:
			continue

		var gravity = strength / max(distance, 10.0)
		total_force += direction.normalized() * gravity

	return total_force



	
func get_closest_planet(position: Vector2):
	var closest = null
	var closest_distance = INF

	for planet in planets:
		var distance = position.distance_to(planet.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = planet

	return closest
	
func can_land(position: Vector2):
	var planet = get_closest_planet(position)
	if planet == null:
		return null

	var distance = position.distance_to(planet.global_position)
	if distance <= planet.landing_radius:
		return planet

	return null
