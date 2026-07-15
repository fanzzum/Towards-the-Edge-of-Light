extends CharacterBody2D

# ===== Movement =====

@export var thrust_force := 3000.0
@export var rotation_speed := 1.25

# ===== Gravity =====

@export var gravity_strength := 50000000.0

# ===== Prediction =====

@export var trajectory_steps := 300
@onready var trajectory_line: Line2D = $TrajectoryLine

# ===== Runtime =====

# ===== OnReady =====





enum ShipState {
	LAUNCH,
	FLIGHT,
	LANDING,
	LANDED
}
var current_state = ShipState.FLIGHT
var velocity_vector: Vector2 = Vector2.ZERO


func _physics_process(delta):
	if current_state == ShipState.LANDING:
		return
		
	if current_state == ShipState.FLIGHT:
		handle_rotation(delta)
		handle_thrust(delta)
		apply_planet_gravity(delta)

	velocity = velocity_vector
	move_and_slide()
	velocity_vector = velocity
	draw_trajectory()
	
	var landing_planet = GravityManager.can_land(global_position)

	if landing_planet:
		current_state = ShipState.LANDING
	else:
		current_state = ShipState.FLIGHT
	
		
	if Input.is_action_just_pressed("initiate_landing"):
		var planet = GravityManager.can_land(global_position)
		if planet:
			current_state = ShipState.LANDING


func handle_rotation(delta):

	var input = Input.get_axis("rotate_left", "rotate_right")

	rotation += input * rotation_speed * delta


func handle_thrust(delta):

	if Input.is_action_pressed("thrust"):

		var direction = Vector2.UP.rotated(rotation)

		velocity_vector += direction * thrust_force * delta


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
