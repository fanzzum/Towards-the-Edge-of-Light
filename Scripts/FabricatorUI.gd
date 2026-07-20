extends CanvasLayer

var part_db = {
	"thruster_power": {"socket": "thruster", "res": "res://Resources/PowerThruster.tres", "cost": {"titanium": 5, "lead": 5}},
	"thruster_vector": {"socket": "thruster", "res": "res://Resources/VectorThruster.tres", "cost": {"titanium": 10, "copper": 5}},
	"thruster_efficiency": {"socket": "thruster", "res": "res://Resources/BasicThruster.tres", "cost": {"titanium": 2}},
	
	"sensor_wide": {"socket": "sensor", "res": "res://Resources/BasicSensor.tres", "cost": {"copper": 5, "silver": 2}},
	"sensor_precision": {"socket": "sensor", "res": "res://Resources/PrecisionSensor.tres", "cost": {"silver": 8}},
	"sensor_long": {"socket": "sensor", "res": "res://Resources/LongSensor.tres", "cost": {"silver": 5, "copper": 5}},
	
	"stabilizer_gyro": {"socket": "stabilizer", "res": "res://Resources/GyroStabilizer.tres", "cost": {"lead": 5, "titanium": 5}},
	"stabilizer_reaction": {"socket": "stabilizer", "res": "res://Resources/ReactionStabilizer.tres", "cost": {"copper": 5, "silver": 5}},
	"stabilizer_balanced": {"socket": "stabilizer", "res": "res://Resources/BasicFin.tres", "cost": {"titanium": 3}},
	
	"utility_armor": {"socket": "utility", "res": "res://Resources/BasicArmor.tres", "cost": {"lead": 10}},
	"utility_cargo": {"socket": "utility", "res": "res://Resources/CargoUtility.tres", "cost": {"titanium": 5, "copper": 5}},
	"utility_battery": {"socket": "utility", "res": "res://Resources/BatteryUtility.tres", "cost": {"silver": 5, "lead": 5}}
}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui_displays() 
	
	for part_name in part_db:
		var btn = $Panel/GridContainer.get_node_or_null(part_name)
		if btn:
			# 1. Load the resource file for this specific button
			var part_resource = load(part_db[part_name].res)
			
			# 2. Check if it has an icon, and apply it to the button
			if "icon" in part_resource and part_resource.icon != null:
				btn.icon = part_resource.icon
				
				# Optional: Adjust Godot's built-in icon settings to make it look nice
				btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
				btn.expand_icon = true 
			
			# 3. Add the price tag text (Your existing code)
			var cost_str = "\n" 
			var cost_dict = part_db[part_name].cost
			
			for mat in cost_dict:
				cost_str += str(cost_dict[mat]) + " " + mat.capitalize() + ", "
			
			cost_str = cost_str.trim_suffix(", ")
			btn.text += cost_str



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
	var status_label = $Panel/StatusLabel # Grab the new label

	if GameState.can_afford(cost):
		GameState.deduct_materials(cost)
		GameState.equip_part(socket, part_resource)
		update_ui_displays()
		
		# Show success in game
		status_label.text = "Success! Equipped: " + part_resource.resource_path.get_file()
		status_label.add_theme_color_override("font_color", Color(0, 1, 0)) # Green text
		return true
	else:
		# Show failure in game
		status_label.text = "Cannot afford upgrade!"
		status_label.add_theme_color_override("font_color", Color(1, 0, 0)) # Red text
		return false

# Updates resource counter labels on the UI
# Updates resource counter labels on the UI
func update_ui_displays() -> void:
	var titanium_node = get_node_or_null("TitaniumLabel")
	if titanium_node: titanium_node.text = "Titanium: " + str(GameState.titanium)
	
	var lead_node = get_node_or_null("LeadLabel")
	if lead_node: lead_node.text = "Lead: " + str(GameState.lead)
	
	var silver_node = get_node_or_null("SilverLabel")
	if silver_node: silver_node.text = "Silver: " + str(GameState.silver)
	
	var copper_node = get_node_or_null("CopperLabel")
	if copper_node: copper_node.text = "Copper: " + str(GameState.copper)
