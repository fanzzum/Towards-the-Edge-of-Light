extends CharacterBody2D

# ===== Movement =====
var launch_data := LaunchData.new()
var ship_stats := ShipStats.new()
var hp: float = 100.0
var armor_threshold: float = 200.0
@onready var ghost_line: Line2D = $GhostLine

const ExplorerScene = preload("res://Scenes/Character/Explorer.tscn")
var spawned_explorer: CharacterBody2D = null
var cargo: Dictionary = {"titanium": 0, "lead": 0, "silver": 0, "copper": 0}
var scan_timer: float = 0.0
var scan_duration: float = 2.0

@export var rotation_speed := 1.25

# ===== Gravity =====

# ===== Prediction =====

@export var trajectory_steps := 300
@onready var trajectory_line: Line2D = $TrajectoryLine

# ===== Runtime =====

# ===== OnReady =====
@export var ship_data : ShipData



var velocity_vector: Vector2 = Vector2.ZERO


func _ready() -> void:
		velocity_vector = Vector2.ZERO



func _physics_process(delta):
	update_ship_stats()

	handle_rotation(delta)
	apply_planet_gravity(delta)
	handle_thrust(delta)
	draw_trajectory()

	velocity = velocity_vector
	move_and_slide()
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		handle_impact(velocity_vector)
		# Bounce slightly off the rock/planet
		velocity_vector = velocity_vector.bounce(collision.get_normal()) * 0.5
	velocity_vector = velocity


func handle_impact(impact_velocity: Vector2):
	var impact_speed = impact_velocity.length()
	var impact_force = ship_stats.total_mass * impact_speed
	
	var damage = max(0, impact_force - armor_threshold)
	
	if damage > 0:
		hp -= damage
		print("Took damage: ", damage, " | HP left: ", hp)
		
		if hp <= 0:
			trigger_destruction()

func trigger_destruction():
	print("Ship destroyed! Returning home...")
	cargo = {"titanium": 0, "lead": 0, "silver": 0, "copper": 0} 
	hp = 100.0
	velocity_vector = Vector2.ZERO
	get_tree().change_scene_to_file("res://Scenes/Surface/SurfaceMap.tscn")

func _process(delta):
	# Find if we are inside any planet's scan zone
	var scannable_planet = null
	for planet in GravityManager.planets:
		if planet.is_player_in_range and planet.is_scannable:
			scannable_planet = planet
			break

	# Handle the hold-to-scan timer
	if scannable_planet:
		if Input.is_action_pressed("scan"):
			scan_timer += delta
			# Optional: Print to console so you can see it working before we make a UI
			print("Scanning... ", round((scan_timer / scan_duration) * 100), "%")

			if scan_timer >= scan_duration:
				complete_scan(scannable_planet)
		else:
			scan_timer = 0.0 # Reset if button released
	else:
		scan_timer = 0.0
		
		

func handle_rotation(delta):

	var input = Input.get_axis("rotate_left", "rotate_right")

	rotation += input * rotation_speed * delta


func handle_thrust(delta):

	if Input.is_action_pressed("thrust"):

		var direction = Vector2.UP.rotated(rotation)

		velocity_vector += (
			direction *
			ship_stats.total_thrust *
			100.0 *
			delta
		)

func apply_planet_gravity(delta):

	velocity_vector += GravityManager.calculate_gravity(global_position) * delta
		

func draw_trajectory():
	trajectory_line.clear_points()
	var simulated_position = global_position
	var simulated_velocity = velocity_vector
	var dt = 1.0 / 60.0

	# 1. Create a radar fade effect (Cyan to Transparent)
	var fade_gradient = Gradient.new()
	fade_gradient.set_color(0, Color(0, 1, 1, 1)) # Solid at the ship
	fade_gradient.set_color(1, Color(0, 1, 1, 0)) # Invisible at the end
	trajectory_line.gradient = fade_gradient

	# 2. Limit prediction distance based on Sensor Quality
	# Base 50 steps for free, plus extra steps based on your sensors, capped at your max
	var max_active_steps = int(clamp(50 + (ship_stats.sensor_quality * 10), 50, trajectory_steps))

	for i in range(max_active_steps):
		simulated_velocity += GravityManager.calculate_gravity(simulated_position) * dt
		simulated_position += simulated_velocity * dt
		
		trajectory_line.add_point(to_local(simulated_position))

		var hit = false
		for planet in GravityManager.planets:
			# Added the 6.0 multiplier here to account for your new 6x scale!
			if simulated_position.distance_to(planet.global_position) <= (planet.planet_radius * 6.0):
				hit = true
				break

		if hit:
			break



func update_ship_stats():

	ship_stats.total_mass = 0.0
	ship_stats.total_thrust = 0.0
	ship_stats.sensor_quality = 0.0
	ship_stats.stability = 0.0

	for socket in ship_data.sockets:

		if socket.installed_part == null:
			continue

		var part = socket.installed_part

		ship_stats.total_mass += part.mass
		ship_stats.total_thrust += part.thrust
		ship_stats.sensor_quality += part.sensor_quality
		ship_stats.stability += part.stability

	calculate_center_of_mass()

	calculate_moment_of_inertia()
	
	
func calculate_center_of_mass():

	if ship_stats.total_mass <= 0:

		ship_stats.center_of_mass = Vector2.ZERO

		return

	var weighted_sum := Vector2.ZERO

	for socket in ship_data.sockets:

		if socket.installed_part == null:
			continue

		weighted_sum += socket.local_position * socket.installed_part.mass

	ship_stats.center_of_mass = weighted_sum / ship_stats.total_mass
	
	
	
	
func calculate_moment_of_inertia():

	ship_stats.moment_of_inertia = 0.0

	for socket in ship_data.sockets:

		if socket.installed_part == null:
			continue

		var distance = socket.local_position.distance_to(
			ship_stats.center_of_mass
		)

		ship_stats.moment_of_inertia += (
			socket.installed_part.mass *
			distance *
			distance
		)
		
		
		
func complete_scan(planet):
	scan_timer = 0.0
	planet.is_scannable = false 

	if planet.data and planet.data.scan_rewards:
		# Send directly to global GameState so the Fabricator can use them!
		GameState.titanium += planet.data.scan_rewards.titanium
		GameState.lead += planet.data.scan_rewards.lead
		GameState.silver += planet.data.scan_rewards.silver
		GameState.copper += planet.data.scan_rewards.copper
		
		# Keep local cargo updated just for your DebugHUD to read
		cargo["titanium"] += planet.data.scan_rewards.titanium
		cargo["lead"] += planet.data.scan_rewards.lead
		cargo["silver"] += planet.data.scan_rewards.silver
		cargo["copper"] += planet.data.scan_rewards.copper

		print("Scan complete! GameState Titanium: ", GameState.titanium)



func apply_equipped_parts() -> void:
	# Matches new parts from GameState to the correct sockets in ship_data
	for socket_name in GameState.equipped_parts:
		var new_part = GameState.equipped_parts[socket_name]
		for socket in ship_data.sockets:
			# If the socket's current part type matches the new part type, overwrite it!
			if socket.installed_part != null and socket.installed_part.part_type == new_part.part_type:
				socket.installed_part = new_part


func draw_ghost_line(target_pos: Vector2):
	ghost_line.clear_points()
	var sim_pos = global_position
	var sim_vel = (target_pos - global_position).normalized() * 500.0 # Estimate 500 speed
	var dt = 1.0 / 60.0
	
	for i in range(100): # Predict 100 steps
		sim_vel += GravityManager.calculate_gravity(sim_pos) * dt
		sim_pos += sim_vel * dt
		ghost_line.add_point(to_local(sim_pos))
