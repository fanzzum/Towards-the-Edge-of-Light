extends Node

@export var planet_scene: PackedScene
@export var planet_textures: Array[Texture2D] = []
@export var star_textures: Array[Texture2D] = []

# Material profiles matching our 4 distance rings
var material_profiles = [
	preload("res://Resources/Materials/Tier1_Inner.tres"),
	preload("res://Resources/Materials/Tier2_Mid.tres"),
	preload("res://Resources/Materials/Tier3_Far.tres"),
	preload("res://Resources/Materials/Tier4_Extreme.tres")
]

var ring_distances = [2000, 5000, 8000, 12000]
var planets_per_ring = [4, 6, 6, 4]

# Keep track of which sprite index we are on so each planet looks unique
var planet_sprite_index : int = 0

func _ready():
	generate_system()

func generate_system():
	# --- Generate Home Planet ---
	var home_planet = planet_scene.instantiate()
	home_planet.global_position = Vector2.ZERO
	
	var home_data = PlanetData.new()
	home_data.planet_name = "Home"
	home_data.gravity_strength = 60000.0 
	home_data.gravity_radius = 2000.0
	home_data.planet_radius = 120.0
	home_data.landing_radius = 300.0
	home_planet.data = home_data
	home_planet.is_scannable = false 
	
	add_child(home_planet)
	
	if planet_textures.size() > 0:
		var visual = home_planet.get_node("OrbitVisual")
		visual.texture = planet_textures[0]
		visual.hframes = 50
		visual.vframes = 2
		visual.frame = 0

	var last_spawned_planet = null

	# --- Generate Ring Planets ---
	for ring_index in range(ring_distances.size()):
		var distance = ring_distances[ring_index]
		var count = planets_per_ring[ring_index]
		var angle_step = TAU / count
		
		for i in range(count):
			var angle = (i * angle_step) + randf_range(-0.3, 0.3)
			var distance_jitter = randf_range(-300, 300)
			var spawn_pos = Vector2(cos(angle), sin(angle)) * (distance + distance_jitter)
			
			var new_planet = planet_scene.instantiate()
			new_planet.global_position = spawn_pos
			
			var new_data = PlanetData.new()
			new_data.gravity_strength = 80000.0 * (ring_index + 1)
			new_data.gravity_radius = 3000.0 + (ring_index * 200.0)
			new_data.planet_radius = 120.0
			new_data.scan_rewards = material_profiles[ring_index]
			new_planet.data = new_data
			
			if planet_textures.size() > 0:
				var visual_index = planet_sprite_index % planet_textures.size()
				var visual = new_planet.get_node("OrbitVisual")
				visual.texture = planet_textures[visual_index]
				visual.hframes = 50
				visual.vframes = 2
				visual.frame = 0
				
			add_child(new_planet)
			planet_sprite_index += 1
			
			if ring_index == ring_distances.size() - 1:
				last_spawned_planet = new_planet

	# --- Mark Final Destination Planet ---
	if last_spawned_planet != null:
		last_spawned_planet.data.is_final_planet = true
		last_spawned_planet.modulate = Color(2.0, 1.5, 0.5) # Glowing gold!
		GameState.final_planet_position = last_spawned_planet.global_position

	# --- Generate Stars ---
	var star_angles = [0.0, TAU / 3.0, (2.0 * TAU) / 3.0]
	for s in range(3):
		var star_pos = Vector2(cos(star_angles[s]), sin(star_angles[s])) * 11000.0
		
		var new_star = planet_scene.instantiate()
		new_star.global_position = star_pos
		
		var star_data = PlanetData.new()
		star_data.gravity_strength = 5000.0
		star_data.gravity_radius = 1200.0
		star_data.planet_radius = 250.0
		
		new_star.data = star_data
		new_star.is_scannable = false
		
		if star_textures.size() > 0:
			var visual = new_star.get_node("OrbitVisual")
			visual.texture = star_textures[s % star_textures.size()]
			visual.hframes = 50
			visual.vframes = 2
			visual.frame = 0
			
		add_child(new_star)
