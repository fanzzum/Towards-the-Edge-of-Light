class_name ShipPart
extends Resource

enum PartType {
	THRUSTER,
	SENSOR,
	STABILIZER,
	PLATING,
	LANDING_GEAR
}

@export var part_name : String = ""

@export var part_type : PartType

@export_multiline
var description : String = ""

# Gameplay
@export var mass : float = 0.0

@export var thrust : float = 0.0

@export var sensor_quality : float = 0.0

@export var stability : float = 0.0

# Art

@export var sprite : Texture2D

@export var icon : Texture2D
