extends CharacterBody2D

# ===== Movement =====
var launch_data := LaunchData.new()
var ship_stats := ShipStats.new()
var hp: float = 100.0
var armor_threshold: float = 200.0
@onready var ghost_line: Line2D = $GhostLine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const ExplorerScene = preload("res://Scenes/Character/Explorer.tscn")
var spawned_explorer: CharacterBody2D = null
var cargo: Dictionary = {"titanium": 0, "lead": 0, "silver": 0, "copper": 0}
var scan_timer: float = 0.0
var scan_duration: float = 2.0
var flight_time: float = 0.0
@onready var thrust_audio: AudioStreamPlayer2D = $ThrustAudio



@export var rotation_speed := 1.25


enum FlightState { PRE_LAUNCH, FLIGHT }
var current_state: FlightState = FlightState.PRE_LAUNCH
var pre_launch_power: float = 0.0
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
	
	# Spawn on top of the planet surface (300px up from center to clear scaled radius)
	var spawn_center = GameState.current_planet_position
	global_position = spawn_center + Vector2(0, -300.0) 
	
	current_state = FlightState.PRE_LAUNCH
	pre_launch_power = 0.0
	
	apply_equipped_parts()
	update_ship_stats()



func _physics_process(delta):
	if current_state == FlightState.FLIGHT and hp > 0:
		flight_time += delta
	update_ship_stats()

	if current_state == FlightState.PRE_LAUNCH:
		handle_pre_launch(delta)
		draw_trajectory()
	else:
		handle_rotation(delta)
		apply_planet_gravity(delta)
		handle_thrust(delta)
		draw_trajectory()

		velocity = velocity_vector
		move_and_slide()
		if get_slide_collision_count() > 0:
			var collision = get_slide_collision(0)
			handle_impact(velocity_vector)
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
	set_physics_process(false) 
	
	animated_sprite.play("explosion")
	await animated_sprite.animation_finished 
	
	# Spawn the Death Menu
	var menu_scene = preload("res://Scenes/DeathMenu.tscn")
	var menu_instance = menu_scene.instantiate()
	get_tree().root.add_child(menu_instance)
	
	# Pass the stats to the menu (using your existing cargo dictionary)
	menu_instance.setup(flight_time, cargo)
	
	# Reset position data and delete the ship
	GameState.current_planet_position = Vector2.ZERO
	queue_free()


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
	
	var closest = GravityManager.get_closest_planet(global_position)
	if closest:
		draw_ghost_line(closest.global_position)
	
	if Input.is_action_just_pressed("land"):
		attempt_landing()
		
	if GameState.final_planet_position != Vector2.ZERO:
		if has_node("Arrow"):
			# Angle to target + 90 degree offset for a downward-pointing sprite
			$Arrow.global_rotation = global_position.angle_to_point(GameState.final_planet_position) + (PI / 2.0)



func attempt_landing():
	var landable_planet = GravityManager.can_land(global_position)
	
	if landable_planet:
		var speed = velocity_vector.length()
		var safe_landing_speed = 350.0 
		
		if speed <= safe_landing_speed:
			print("Landed safely on ", landable_planet.name)
			GameState.current_planet_position = landable_planet.global_position
			
			# Check if it's the winning planet
			if "data" in landable_planet and landable_planet.data.is_final_planet:
				print("GAME BEATEN!")
				# Create a WinScreen.tscn later and load it here:
				get_tree().change_scene_to_file("res://Scenes/UI/WinScreen.tscn")
				return
			
			get_tree().change_scene_to_file("res://Scenes/Surface/SurfaceMap.tscn")
		else:
			print("Moving too fast! Speed: ", speed)


func handle_rotation(delta):
	var input = Input.get_axis("rotate_left", "rotate_right")
	
	# Base speed 1.25, scaled by equipped fins/stabilizer stability
	var effective_rotation_speed = rotation_speed + (ship_stats.stability * 0.1)
	
	rotation += input * effective_rotation_speed * delta


func handle_thrust(delta):
	if Input.is_action_pressed("thrust"):
		var direction = Vector2.UP.rotated(rotation)
		var current_mass = max(1.0, ship_stats.total_mass)
		var acceleration = (ship_stats.total_thrust * 1000.0) / current_mass
		
		velocity_vector += direction * acceleration * delta
		
		# --- Sound Logic ---
		if not thrust_audio.playing:
			thrust_audio.play()
		
		# --- Animation Logic ---
		if animated_sprite.animation == "idle":
			animated_sprite.play("thrust")
		elif animated_sprite.animation == "thrust" and animated_sprite.frame == 3:
			animated_sprite.play("fly")
			
	else:
		if thrust_audio.playing:
			thrust_audio.stop()
		animated_sprite.play("idle")
		
		

func apply_planet_gravity(delta):

	velocity_vector += GravityManager.calculate_gravity(global_position) * delta
		

func draw_trajectory():
	trajectory_line.clear_points()
	var simulated_position = global_position
	var simulated_velocity = velocity_vector
	
	# If aiming, preview the blast we are about to fire!
	if current_state == FlightState.PRE_LAUNCH:
		simulated_velocity = Vector2.UP.rotated(rotation) * pre_launch_power
		
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
		if i > 5: # Add this check!
			for planet in GravityManager.planets:
				if simulated_position.distance_to(planet.global_position) <= planet.planet_radius:
					hit = true
					break

		if hit:
			break



func update_ship_stats():
	if ship_data == null: return # Guard clause

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
	if ship_data == null or ship_stats.total_mass <= 0:
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
	if ship_data == null: return

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



func complete_scan(target):
	scan_timer = 0.0
	target.is_scannable = false 

	# Check if target is a beacon
	if "is_beacon" in target and target.is_beacon:
		GameState.last_checkpoint = target.global_position
		print("Checkpoint logged at: ", GameState.last_checkpoint)
		return

	# Otherwise, it's a planet. Process materials:
	if target.data and target.data.scan_rewards:
		GameState.titanium += target.data.scan_rewards.titanium
		GameState.lead += target.data.scan_rewards.lead
		GameState.silver += target.data.scan_rewards.silver
		GameState.copper += target.data.scan_rewards.copper
		
		cargo["titanium"] += target.data.scan_rewards.titanium
		cargo["lead"] += target.data.scan_rewards.lead
		cargo["silver"] += target.data.scan_rewards.silver
		cargo["copper"] += target.data.scan_rewards.copper


func apply_equipped_parts() -> void:
	if ship_data == null: return
	
	for socket_type_key in GameState.equipped_parts:
		var new_part = GameState.equipped_parts[socket_type_key]
		if new_part == null: continue
		
		# Match socket using part_type or socket category
		for socket in ship_data.sockets:
			if socket.installed_part != null:
				# Match if they share the same enum/type
				if socket.installed_part.part_type == new_part.part_type:
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



func handle_pre_launch(delta):
	handle_rotation(delta) 
	
	var power_input = Input.get_axis("ui_down", "ui_up") 
	var current_mass = max(1.0, ship_stats.total_mass)
	var max_possible_accel = (ship_stats.total_thrust * 1000.0) / current_mass
	
	pre_launch_power += power_input * max_possible_accel * delta * 0.5 
	pre_launch_power = clamp(pre_launch_power, 0.0, max_possible_accel)
	
	# --- Pre-Launch Animation ---
	if pre_launch_power > 0:
		animated_sprite.play("thrust")
	else:
		animated_sprite.play("idle")
	
	if Input.is_action_just_pressed("ui_accept"):
		velocity_vector = Vector2.UP.rotated(rotation) * pre_launch_power
		current_state = FlightState.FLIGHT
		print("KICK OFF! Velocity: ", velocity_vector.length())
