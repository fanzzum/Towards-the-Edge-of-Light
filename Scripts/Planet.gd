extends StaticBody2D

@export var data : PlanetData

func _ready():
	GravityManager.register_planet(self)


func _exit_tree():
	GravityManager.unregister_planet(self)

# Replace the old functions at the bottom with these clean getters:
var gravity_strength: float:
	get: return data.gravity_strength

var gravity_radius: float:
	get: return data.gravity_radius

var planet_radius: float:
	get: return data.planet_radius

var landing_radius: float:
	get: return data.landing_radius
