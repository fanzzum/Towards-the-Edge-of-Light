extends Node2D

@export var radius := 180.0

func _draw():

	draw_arc(
		Vector2.ZERO,
		radius,
		0,
		TAU,
		100,
		Color.GREEN,
		2
	)

func _ready():
	queue_redraw()
