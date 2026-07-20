extends CanvasLayer

var part_db = {
	"thruster_power": {"socket": "thruster", "res": "res://Resources/BasicThruster.tres", "cost": {"titanium": 5, "lead": 5}},
	"thruster_vector": {"socket": "thruster", "res": "res://Resources/BasicThruster.tres", "cost": {"titanium": 10, "copper": 5}},
	"thruster_efficiency": {"socket": "thruster", "res": "res://Resources/BasicThruster.tres", "cost": {"titanium": 2}},
	"sensor_wide": {"socket": "sensor", "res": "res://Resources/BasicSensor.tres", "cost": {"copper": 5, "silver": 2}},
	"sensor_precision": {"socket": "sensor", "res": "res://Resources/BasicSensor.tres", "cost": {"silver": 8}},
	"sensor_long": {"socket": "sensor", "res": "res://Resources/BasicSensor.tres", "cost": {"silver": 5, "copper": 5}},
	"stabilizer_gyro": {"socket": "stabilizer", "res": "res://Resources/BasicFin.tres", "cost": {"lead": 5, "titanium": 5}},
	"stabilizer_reaction": {"socket": "stabilizer", "res": "res://Resources/BasicFin.tres", "cost": {"copper": 5, "silver": 5}},
	"stabilizer_balanced": {"socket": "stabilizer", "res": "res://Resources/BasicFin.tres", "cost": {"titanium": 3}},
	"utility_armor": {"socket": "utility", "res": "res://Resources/BasicArmor.tres", "cost": {"lead": 10}},
	"utility_cargo": {"socket": "utility", "res": "res://Resources/BasicArmor.tres", "cost": {"titanium": 5, "copper": 5}},
	"utility_battery": {"socket": "utility", "res": "res://Resources/BasicArmor.tres", "cost": {"silver": 5, "lead": 5}}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_part_pressed(button_name: String) -> void:
	if part_db.has(button_name):
		var data = part_db[button_name]
		try_purchase_part(data.socket, load(data.res), data.cost)



func try_purchase_part(socket: String, part_resource: Resource, cost: Dictionary) -> bool:
	if GameState.can_afford(cost):
		GameState.deduct_materials(cost)
		GameState.equip_part(socket, part_resource)
		update_ui_displays()
		print("Successfully crafted and equipped: ", part_resource.resource_path)
		return true
	else:
		print("Cannot afford upgrade!")
		return false

# Updates resource counter labels on the UI
func update_ui_displays() -> void:
	if has_node("TitaniumLabel"): $TitaniumLabel.text = "Titanium: " + str(GameState.titanium)
	if has_node("LeadLabel"): $LeadLabel.text = "Lead: " + str(GameState.lead)
	if has_node("SilverLabel"): $SilverLabel.text = "Silver: " + str(GameState.silver)
	if has_node("CopperLabel"): $CopperLabel.text = "Copper: " + str(GameState.copper)
