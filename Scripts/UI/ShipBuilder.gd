extends CanvasLayer

@onready var socket_list = $Panel/HBoxContainer/SocketList
@onready var part_list = $Panel/HBoxContainer/PartList
@onready var close_button = $Panel/CloseButton

var ship_data: ShipData
var selected_socket_index: int = -1

func _ready():
	close_button.pressed.connect(_on_close_pressed)

func open(data: ShipData):
	ship_data = data
	refresh_ui()

func refresh_ui():
	for child in socket_list.get_children(): child.queue_free()
	for child in part_list.get_children(): child.queue_free()

	# Generate 6 socket buttons
	for i in range(ship_data.sockets.size()):
		var socket = ship_data.sockets[i]
		var btn = Button.new()
		var part_name = "Empty"
		if socket.installed_part:
			part_name = socket.installed_part.resource_name
		
		btn.text = "Socket " + str(i + 1) + "\n[" + part_name + "]"
		btn.pressed.connect(func(): select_socket(i))
		socket_list.add_child(btn)

	# Generate inventory buttons if a socket is selected
	if selected_socket_index != -1:
		var unequip_btn = Button.new()
		unequip_btn.text = "-- Unequip --"
		unequip_btn.pressed.connect(func(): equip_part(null))
		part_list.add_child(unequip_btn)

		for part in ship_data.unlocked_parts:
			var btn = Button.new()
			btn.text = part.resource_name + "\nMass: " + str(part.mass) + " | Thrust: " + str(part.thrust)
			btn.pressed.connect(func(): equip_part(part))
			part_list.add_child(btn)

func select_socket(index: int):
	selected_socket_index = index
	refresh_ui()

func equip_part(part: ShipPart):
	if selected_socket_index != -1:
		var old_part = ship_data.sockets[selected_socket_index].installed_part
		
		# Put the old part back into inventory if it exists
		if old_part != null and not ship_data.unlocked_parts.has(old_part):
			ship_data.unlocked_parts.append(old_part)
			
		# Install the new part
		ship_data.sockets[selected_socket_index].installed_part = part
		
		# Remove the newly installed part from inventory
		if part != null:
			ship_data.unlocked_parts.erase(part)
			
	selected_socket_index = -1
	refresh_ui()

func _on_close_pressed():
	var explorer = get_tree().current_scene.get_node_or_null("Explorer")
	if explorer == null: explorer = get_tree().current_scene.find_child("Explorer")
	if explorer: explorer.is_active = true
	queue_free()
