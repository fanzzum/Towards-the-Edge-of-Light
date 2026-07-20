extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Hardcoded gravity fallback vector for pixel-space mechanics
const FALLBACK_GRAVITY = 980.0 

@onready var start_scale_x: float = $Sprite2D.scale.x

func _physics_process(delta: float) -> void:
	# 1. Apply robust gravity fallback
	if not is_on_floor():
		velocity.y += FALLBACK_GRAVITY * delta

	# 2. Handle Jump input
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Calculate horizontal movement using your input map names
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
		# Flip the sprite visuals cleanly
		if direction > 0:
			$Sprite2D.scale.x = start_scale_x
		elif direction < 0:
			$Sprite2D.scale.x = -start_scale_x
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Execute movement loops
	move_and_slide()
