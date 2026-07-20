extends Node

# Inventory
var titanium: int = 10  # Starting with 10 for testing
var lead: int = 10
var silver: int = 0
var copper: int = 0
var equipped_parts: Dictionary = {}
var final_planet_position: Vector2 = Vector2.ZERO

# Ship Stats
var current_thruster: String = "Efficiency" 
var max_thrust: float = 500.0
var max_health: int = 100

var current_planet_position: Vector2 = Vector2.ZERO
var spawn_at_checkpoint: bool = false

# Checks if the player has enough materials for a given cost dictionary
func can_afford(cost: Dictionary) -> bool:
	for mat in cost:
		if get(mat) == null or get(mat) < cost[mat]:
			return false
	return true

# Deducts materials from player inventory
func deduct_materials(cost: Dictionary) -> void:
	for mat in cost:
		set(mat, get(mat) - cost[mat])

# Equips a part into the designated ship socket
func equip_part(socket: String, part_resource: Resource) -> void:
	equipped_parts[socket] = part_resource
