extends StaticBody2D

var is_scannable: bool = true
var is_player_in_range: bool = false
var is_beacon: bool = true

# Dummy values so GravityManager doesn't throw errors
var gravity_radius: float = 0.0
var gravity_strength: float = 0.0
var planet_radius: float = 16.0
var landing_radius: float = 0.0

func _ready():
	GravityManager.register_planet(self) 
	if has_node("ScanZone"):
		$ScanZone.body_entered.connect(_on_body_entered)
		$ScanZone.body_exited.connect(_on_body_exited)

func _exit_tree():
	GravityManager.unregister_planet(self)

func _on_body_entered(body):
	if body.name == "Ship":
		is_player_in_range = true

func _on_body_exited(body):
	if body.name == "Ship":
		is_player_in_range = false
