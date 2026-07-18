extends CanvasLayer

@onready var left_card: Button = $HBoxContainer/LeftCard
@onready var right_card: Button = $HBoxContainer/RightCard

var left_part: ShipPart
var right_part: ShipPart
@onready var close_button: Button = $CloseButton

func _ready():
	left_card.pressed.connect(_on_left_selected)
	right_card.pressed.connect(_on_right_selected)
	close_button.pressed.connect(_on_close_pressed)
	hide()

func _on_close_pressed():
	# Back out safely without applying blueprints or breaking the ruin
	close_and_cleanup()

func open_choice(part_a: ShipPart, part_b: ShipPart):
	left_part = part_a
	right_part = part_b
	
	# In a real game, you'd use rich text labels for stats. For now, simple text:
	left_card.text = part_a.resource_name + "\nMass: " + str(part_a.mass)
	right_card.text = part_b.resource_name + "\nMass: " + str(part_b.mass)
	
	show()

func get_ship_data() -> ShipData:
	var ship = get_tree().current_scene.get_node_or_null("Ship")
	if ship == null:
		ship = get_tree().current_scene.find_child("Ship")
	return ship.ship_data if ship else null

func _on_left_selected():
	var data = get_ship_data()
	if data and not data.unlocked_parts.has(left_part):
		data.unlocked_parts.append(left_part)
	print("Unlocked: ", left_part.resource_name)
	close_and_cleanup()

func _on_right_selected():
	var data = get_ship_data()
	if data and not data.unlocked_parts.has(right_part):
		data.unlocked_parts.append(right_part)
	print("Unlocked: ", right_part.resource_name)
	close_and_cleanup()

func close_and_cleanup():
	hide()
	# Find the explorer in the scene and turn their movement back on
	var explorer = get_tree().current_scene.get_node_or_null("Explorer")
	if explorer == null:
		explorer = get_tree().current_scene.find_child("Explorer")
	if explorer:
		explorer.is_active = true
		
	queue_free()
