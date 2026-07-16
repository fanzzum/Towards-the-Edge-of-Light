class_name ShipSocket
extends Resource

enum SocketType {

	NOSE,
	LEFT,
	RIGHT,
	TOP,
	BOTTOM,
	REAR
}

@export var socket_type : SocketType

@export var local_position : Vector2

@export var installed_part : ShipPart
