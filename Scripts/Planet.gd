class_name Planet
extends StaticBody2D

@export var data: PlanetData
@export var is_scannable: bool = true
@export var is_final_planet: bool = false
# Scale all planet visuals & collisions by this factor
@export var visual_scale: float = 4.0

# Visual Exports
@export var planet_texture: Texture2D
@export var h_frames: int = 50
@export var v_frames: int = 2
@export var animation_speed: float = 0.1

@onready var orbit_visual: Sprite2D = $OrbitVisual

var is_player_in_range: bool = false
var frame_timer: float = 0.0

func _ready():
	GravityManager.register_planet(self)
	
	# 1. Apply global visual scale
	scale = Vector2(visual_scale, visual_scale)

	# 2. Setup OrbitVisual texture & grid
	if planet_texture and orbit_visual:
		orbit_visual.texture = planet_texture
		orbit_visual.hframes = h_frames
		orbit_visual.vframes = v_frames
		orbit_visual.frame = 0
		orbit_visual.modulate.a = 1.0

	# 3. Connect ScanZone signals safely
	if has_node("ScanZone"):
		var scan_zone = $ScanZone
		if not scan_zone.body_entered.is_connected(_on_body_entered):
			scan_zone.body_entered.connect(_on_body_entered)
		if not scan_zone.body_exited.is_connected(_on_body_exited):
			scan_zone.body_exited.connect(_on_body_exited)

func _process(delta):
	if orbit_visual and orbit_visual.texture:
		frame_timer += delta
		if frame_timer >= animation_speed:
			frame_timer = 0.0
			var total_frames = orbit_visual.hframes * orbit_visual.vframes
			if total_frames > 0:
				orbit_visual.frame = (orbit_visual.frame + 1) % total_frames

func _exit_tree():
	GravityManager.unregister_planet(self)

# --- Auto-Calculated Radius & Gravity Properties ---

var planet_radius: float:
	get:
		if orbit_visual and orbit_visual.texture:
			# Automatically calculates radius from the actual texture frame size * scale
			var frame_width = orbit_visual.texture.get_width() / float(orbit_visual.hframes)
			return (frame_width / 2.0) * scale.x
		return data.planet_radius if data else 64.0

var gravity_strength: float:
	get: return data.gravity_strength if data else 80000.0

var gravity_radius: float:
	get: return data.gravity_radius if data else 2000.0

var landing_radius: float:
	get: return data.landing_radius if data else 350.0

func _on_body_entered(body):
	if body.name == "Ship":
		is_player_in_range = true

func _on_body_exited(body):
	if body.name == "Ship":
		is_player_in_range = false
