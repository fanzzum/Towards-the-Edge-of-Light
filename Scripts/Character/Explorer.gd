extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const FALLBACK_GRAVITY = 980.0 

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += FALLBACK_GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
		if direction > 0:
			animated_sprite.play("walk_right")
		elif direction < 0:
			animated_sprite.play("walk_left")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")

	move_and_slide()
