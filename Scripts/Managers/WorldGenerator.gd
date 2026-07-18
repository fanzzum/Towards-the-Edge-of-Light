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
	# --- Generate the 20 Planets ---
	for ring_index in range(ring_distances.size()):
		var distance = ring_distances[ring_index]
		var count = planets_per_ring[ring_index]
		var angle_step = TAU / count
		
		for i in range(count):
			var angle = (i * angle_step) + randf_range(-0.4, 0.4)
			var distance_jitter = randf_range(-500, 500)
			var spawn_pos = Vector2(cos(angle), sin(angle)) * (distance + distance_jitter)
			
			var new_planet = planet_scene.instantiate()
			new_planet.global_position = spawn_pos
			new_planet.scale = Vector2(6.0, 6.0)
			
			# Dynamic Data Injection
			var new_data = PlanetData.new()
			
			# Scale gravity strength based on the ring tier
			new_data.gravity_strength = 400000.0 * (ring_index + 1)
			new_data.gravity_radius = 3000.0 + (ring_index * 200.0)
			new_data.planet_radius = 100.0
			
			# Assign the pre-configured material rewards
			new_data.scan_rewards = material_profiles[ring_index]
			new_planet.data = new_data
			
			# Load your unique spritesheet sequentially (0 to 19)
			# Load your unique spritesheet sequentially (0 to 19)
			if planet_textures.size() > 0:
				var visual_index = planet_sprite_index % planet_textures.size()
				var visual = new_planet.get_node("OrbitVisual")

				visual.texture = planet_textures[visual_index]
				visual.hframes = 50
				visual.vframes = 2
				visual.frame = 0
				
			add_child(new_planet)
			planet_sprite_index += 1

	# --- Generate the 3 Stars ---
	var star_angles = [0.0, TAU / 3.0, (2.0 * TAU) / 3.0] # Spaced evenly out in the sandbox
	for s in range(3):
		var star_pos = Vector2(cos(star_angles[s]), sin(star_angles[s])) * 11000.0 # Placed out in the deep rings
		
		var new_star = planet_scene.instantiate()
		new_star.global_position = star_pos
		
		var star_data = PlanetData.new()
		star_data.gravity_strength = 5000.0 # Document v3: Stars have very weak/no gravity wells
		star_data.gravity_radius = 1200.0
		star_data.planet_radius = 250.0 # Make visual bounds bigger
		
		new_star.data = star_data
		new_star.is_scannable = false # Stars are environmental/hazards, not mining claims[cite: 2]
		
		# Load the unique star spritesheet
		if star_textures.size() > 0:
			var visual = new_star.get_node("OrbitVisual")

			visual.texture = star_textures[s % star_textures.size()]
			visual.hframes = 50
			visual.vframes = 2
			visual.frame = 0
			
		add_child(new_star)
