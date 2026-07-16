extends CharacterBody2D

# ===== Movement =====
var launch_data := LaunchData.new()
var ship_stats := ShipStats.new()

const ExplorerScene = preload("res://Scenes/Character/Explorer.tscn")
var spawned_explorer: CharacterBody2D = null


@export var rotation_speed := 1.25

# ===== Gravity =====

# ===== Prediction =====

@export var trajectory_steps := 300
@onready var trajectory_line: Line2D = $TrajectoryLine

# ===== Runtime =====

# ===== OnReady =====
@export var ship_data : ShipData





enum ShipState {
	LAUNCH,
	FLIGHT,
	LANDING,
	LANDED
}
var current_state = ShipState.FLIGHT
var velocity_vector: Vector2 = Vector2.ZERO


func _ready() -> void:
		velocity_vector = Vector2.ZERO




func _physics_process(delta):
	update_ship_stats()
	
	if current_state == ShipState.FLIGHT:
		handle_rotation(delta)
		handle_thrust(delta)
		apply_planet_gravity(delta)
		draw_trajectory()
		
		if Input.is_action_just_pressed("initiate_landing"):
			var planet = GravityManager.can_land(global_position)
			if planet:
				current_state = ShipState.LANDING
				GravityManager.exclusive_gravity_planet = planet
				planet.is_landing_target = true
				get_tree().call_group("camera", "set_landing_mode", true)
				trajectory_line.clear_points()
				
	elif current_state == ShipState.LANDING:
		var target = GravityManager.exclusive_gravity_planet
		if target:
			var direction_to_planet = global_position.direction_to(target.global_position)
			
			# Smoothly guide down and arrest sideways velocity
			velocity_vector = velocity_vector.lerp(direction_to_planet * 100.0, delta * 2.0)
			
			var distance = global_position.distance_to(target.global_position)
			# Add a larger buffer (e.g., + 25.0 pixels) so it registers right on structural impact
			var landing_threshold = target.planet_radius + 25.0
			
			if distance <= landing_threshold:
				current_state = ShipState.LANDED
				velocity_vector = Vector2.ZERO
				spawn_explorer()

	velocity = velocity_vector
	move_and_slide()
	velocity_vector = velocity




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

	for i in range(trajectory_steps):

		simulated_velocity += GravityManager.calculate_gravity(simulated_position) * dt

		simulated_position += simulated_velocity * dt

		trajectory_line.add_point(to_local(simulated_position))

		var hit = false

		for planet in GravityManager.planets:

			if simulated_position.distance_to(planet.global_position) <= planet.planet_radius:

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



func spawn_explorer():
	if spawned_explorer != null:
		return
		
	spawned_explorer = ExplorerScene.instantiate()
	get_tree().current_scene.add_child(spawned_explorer) 
	spawned_explorer.global_position = global_position
	spawned_explorer.is_active = true
	
	get_tree().call_group("camera", "set_target", spawned_explorer)


func restore_ship_visibility():
	if has_node("Sprite2D"):
		get_node("Sprite2D").visible = true
	for child in get_children():
		if child is Sprite2D:
			child.visible = true
