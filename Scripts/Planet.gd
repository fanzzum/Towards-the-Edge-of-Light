class_name Planet
extends StaticBody2D

@export var data : PlanetData

@onready var orbit_visual: Sprite2D = $OrbitVisual
@onready var surface_visual: Node2D = $SurfaceVisual

var is_landing_target := false

func _ready():
	GravityManager.register_planet(self)
	surface_visual.modulate.a = 0.0
	orbit_visual.modulate.a = 1.0

func _exit_tree():
	GravityManager.unregister_planet(self)

func _process(delta):
	if is_landing_target:
		surface_visual.modulate.a = move_toward(surface_visual.modulate.a, 1.0, delta * 2.0)
		orbit_visual.modulate.a = move_toward(orbit_visual.modulate.a, 0.0, delta * 2.0)
	else:
		surface_visual.modulate.a = move_toward(surface_visual.modulate.a, 0.0, delta * 2.0)
		orbit_visual.modulate.a = move_toward(orbit_visual.modulate.a, 1.0, delta * 2.0)

var gravity_strength: float:
	get: return data.gravity_strength

var gravity_radius: float:
	get: return data.gravity_radius

var planet_radius: float:
	get: return data.planet_radius

var landing_radius: float:
	get: return data.landing_radius
