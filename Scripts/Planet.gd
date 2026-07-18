class_name Planet
extends StaticBody2D

@export var data : PlanetData

@onready var orbit_visual: Sprite2D = $OrbitVisual
var is_scannable: bool = true
var is_player_in_range: bool = false


var frame_timer: float = 0.0
@export var animation_speed: float = 0.1 # Seconds per frame

func _process(delta):
	# Cycle through your 100 spritesheet frames smoothly
	frame_timer += delta
	if frame_timer >= animation_speed:
		frame_timer = 0.0
		# Cycle from frame 0 up to 99, then loop back to 0
		orbit_visual.frame = (orbit_visual.frame + 1) % (orbit_visual.hframes * orbit_visual.vframes)

func _ready():
	GravityManager.register_planet(self) # Keep from original code
	orbit_visual.modulate.a = 1.0 # Keep from original code

	# ADD these signal connections
	$ScanZone.body_entered.connect(_on_body_entered)
	$ScanZone.body_exited.connect(_on_body_exited)
	

func _exit_tree():
	GravityManager.unregister_planet(self)


var gravity_strength: float:
	get: return data.gravity_strength

var gravity_radius: float:
	get: return data.gravity_radius

var planet_radius: float:
	get: return data.planet_radius

var landing_radius: float:
	get: return data.landing_radius


func _on_body_entered(body):
	if body.name == "Ship":
		is_player_in_range = true

func _on_body_exited(body):
	if body.name == "Ship":
		is_player_in_range = false
