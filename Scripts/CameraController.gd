extends Camera2D

@export var target : Node2D
@export var follow_speed := 8.0
@export var default_zoom := Vector2(1.0, 1.0)
@export var landing_zoom := Vector2(2.5, 2.5)

var target_zoom := default_zoom

func _process(delta):
	if target == null:
		return

	global_position = global_position.lerp(
		target.global_position,
		follow_speed * delta
	)
	
	zoom = zoom.lerp(target_zoom, follow_speed * delta * 0.5)

func set_landing_mode(is_landing: bool):
	if is_landing:
		target_zoom = landing_zoom
	else:
		target_zoom = default_zoom


func set_target(new_target: Node2D):
	target = new_target
