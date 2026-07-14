extends CharacterBody2D

@export var gravity_strength := 90000000.0
@export var thrust_force := 500.0
@export var rotation_speed := 1.25
@onready var trajectory_line: Line2D = $TrajectoryLine

var velocity_vector: Vector2 = Vector2.ZERO


func _physics_process(delta):
	handle_rotation(delta)
	handle_thrust(delta)
	apply_planet_gravity(delta)

	velocity = velocity_vector
	move_and_slide()
	velocity_vector = velocity
	draw_trajectory()


func handle_rotation(delta):

	var input = Input.get_axis("ui_left", "ui_right")

	rotation += input * rotation_speed * delta


func handle_thrust(delta):

	if Input.is_action_pressed("ui_up"):

		var direction = Vector2.UP.rotated(rotation)

		velocity_vector += direction * thrust_force * delta


func apply_planet_gravity(delta):

	for planet in get_tree().get_nodes_in_group("planets"):

		var direction = planet.global_position - global_position

		var distance = direction.length()

		if distance < 10:
			continue

		var gravity = planet.gravity_strength / (distance * distance)

		velocity_vector += direction.normalized() * gravity * delta
		

func draw_trajectory():

	trajectory_line.clear_points()

	var simulated_position = global_position
	var simulated_velocity = velocity_vector

	var dt = 1.0 / 60.0

	for i in range(300):

		for planet in get_tree().get_nodes_in_group("planets"):

			var direction = planet.global_position - simulated_position

			var distance = direction.length()

			if distance < 10:
				continue

			var gravity = planet.gravity_strength / (distance * distance)

			simulated_velocity += direction.normalized() * gravity * dt

		simulated_position += simulated_velocity * dt

		trajectory_line.add_point(
			to_local(simulated_position)
		)
