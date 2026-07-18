extends Label # (Or Panel/Control depending on your node type)

@export var ship: CharacterBody2D

func _process(_delta):
	if ship == null:
		visible = false
		return

	var current_planet = null
	for planet in GravityManager.planets:
		# Check the new range variables we added in Step 143
		if planet.is_player_in_range and planet.is_scannable:
			current_planet = planet
			break

	if current_planet:
		visible = true
		text = "[ Hold F to Scan Planet ]"
	else:
		visible = false
