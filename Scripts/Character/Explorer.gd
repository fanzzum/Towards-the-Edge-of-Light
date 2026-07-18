extends CharacterBody2D

const BlueprintUI = preload("res://Scenes/UI/BlueprintChoice.tscn")

@export var walk_speed := 150.0
var is_active := false
var active_ruin: Area2D = null

func _physics_process(_delta):
	if not is_active:
		return

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * walk_speed
	move_and_slide()



func set_active_ruin(ruin: Area2D):
	active_ruin = ruin



func _unhandled_input(event):
	if not is_active:
		return
		
	# Find the ship in the active scene tree
	var ship = get_tree().current_scene.get_node_or_null("Ship")
	if ship == null:
		ship = get_tree().current_scene.find_child("Ship")
		
	if ship == null:
		return

	# Must be standing near the ship to interact with it
	var near_ship = global_position.distance_to(ship.global_position) < 150.0

	if near_ship:
		# Press Spacebar to board the ship and take off
		if event.is_action_pressed("initiate_landing"):
			ship.initiate_takeoff()
			
		# Press 'B' to open the modular Ship Builder menu directly at the hull
		if event is InputEventKey and event.pressed and event.keycode == KEY_B:
			is_active = false
			velocity = Vector2.ZERO
			
			var builder = load("res://Scenes/UI/ShipBuilder.tscn").instantiate()
			get_tree().current_scene.add_child(builder)
			builder.open(ship.ship_data)
