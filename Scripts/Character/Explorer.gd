extends CharacterBody2D

@export var walk_speed := 150.0
var is_active := false

func _physics_process(_delta):
	if not is_active:
		return

	# You will need to map W,A,S,D or Arrows to these input actions in Project Settings
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = input_dir * walk_speed
	move_and_slide()
