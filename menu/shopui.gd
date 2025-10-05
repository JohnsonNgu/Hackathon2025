extends Node

var player_money = 500

var upgrades = {
	"flamethrower": {"level": 0, "max_level": 3, "costs": [100, 200, 300], "description": ["Costs: 100 Gold\nTest test","",""]},
	"harpoon": {"level": 0, "max_level": 3, "costs": [100, 200, 300], "description": ["","",""]},
	"cannon": {"level": 0, "max_level": 3, "costs": [100, 200, 300], "description": ["","",""]},
	"equilizer": {"level": 0, "max_level": 3, "costs": [100, 200, 300], "description": ["","",""]},
	"shield": {"level": 0, "max_level": 3, "costs": [100, 200, 300], "description": ["","",""]},
	"mines": {"level": 0, "max_level": 3, "costs": [100, 200, 300], "description": ["","",""]},
}

@onready var active_grid = $GUI/VBoxContainer/HBoxContainer/Active/GridContainer
@onready var passive_grid = $GUI/VBoxContainer/HBoxContainer/Passive/GridContainer
@onready var gold = $GUI/VBoxContainer/HBoxContainer2/Gold

func _ready():
	var active_keys = ["flamethrower", "harpoon", "cannon"]
	var passive_keys = ["equilizer", "shield", "mines"]
	
	get_node("GUI/VBoxContainer/HBoxContainer2/Gold").text = "Gold: " + str(player_money)
	
	# Setup active upgrades (6 buttons total: base + 2 upgrades each)
	setup_upgrade_column(active_grid, active_keys, "active")
	
	# Setup passive upgrades (6 buttons total: base + 2 upgrades each)
	setup_upgrade_column(passive_grid, passive_keys, "passive")
	
	# Initial update of all button states
	update_all_buttons()

func setup_upgrade_column(container: HBoxContainer, keys: Array, type: String):
	# Each weapon has its own child container (Flamethrower, Harpoon, etc.)
	# and inside each is a GridContainer with 3 upgrade buttons
	
	for i in range(keys.size()):
		var key = keys[i]
		
		var weapon_container = container.get_child(i)

		# Find the GridContainer inside this weapon container
		var grid_container = null
		var count = 1;
		for button in weapon_container.get_children():
					
			# Store metadata
			button.set_meta("upgrade_key", key)
			button.set_meta("upgrade_level", count)
			button.set_meta("type", type)
			

			
			# Connect signal
			button.pressed.connect(_on_upgrade_button_pressed.bind(button))
			
			# Setup button structure for visual states
			setup_button_visuals(button, key, count)
			
			count += 1
			
func setup_button_visuals(button: Button, key: String, level: int):
	
	var icon = button.get_node_or_null("icon")
	var overlay_dim = button.get_node_or_null("overlay_dim")
	var lock_icon = button.get_node_or_null("lock_icon")
	var tooltip = null
	
	if (button.get_meta("type") == "active"):
		tooltip = button.get_node_or_null("tooltip_active")
	else:
		tooltip = button.get_node_or_null("tooltip_passive")

	if icon:
		var icon_path = "res://assets/shop_icons/%s_%d.png" % [key, level]
		if ResourceLoader.exists(icon_path):
			icon.texture = load(icon_path)
	
	if overlay_dim:
		overlay_dim.visible = false
		overlay_dim.color = Color(0, 0, 0, 0.6)
	
	if lock_icon:
		lock_icon.visible = false
		
	if tooltip:
		tooltip.visible = false
		var label_tooltip = tooltip.get_node_or_null("text")
		label_tooltip.text = upgrades[key]["description"][level-1]

func _on_upgrade_button_pressed(button: Button):
	var key = button.get_meta("upgrade_key")
	var target_level = button.get_meta("upgrade_level")
	var data = upgrades[key]
	
	# Check if this upgrade is already purchased
	if data["level"] >= target_level:
		print(key, "level", target_level, "already purchased!")
		return
	
	# Check if this is the next upgrade in sequence
	if data["level"] != target_level - 1:
		print("Must purchase previous upgrades first!")
		return
	
	# Check if already at max level
	if data["level"] >= data["max_level"]:
		print(key, "is already fully upgraded!")
		return
	
	var cost = data["costs"][target_level-1]
	
	# Check if player has enough money
	if player_money < cost:
		print("Not enough money for", key, "- Need:", cost, "Have:", player_money)
		return
	
	# Purchase logic
	player_money -= cost
	data["level"] += 1
	get_node("GUI/VBoxContainer/HBoxContainer2/Gold").text = "Gold: " + str(player_money)
	print("Upgraded", key, "to level", data["level"], "for", cost, "gold")
	print("Remaining money:", player_money)
	
	# Update all buttons to reflect new state
	update_all_buttons()

func update_all_buttons():
	# Update both active and passive grids
	for grid in active_grid.get_children():
		for button in grid.get_children():
			if button is Button:
				update_button_state(button)
	
	for grid in passive_grid.get_children():
		for button in grid.get_children():
			if button is Button:
				update_button_state(button)

func update_button_state(button: Button):
	var key = button.get_meta("upgrade_key")
	var target_level = button.get_meta("upgrade_level")
	var data = upgrades[key]
	var current_level = data["level"]
	
	var icon = button.get_node_or_null("icon")
	var overlay_dim = button.get_node_or_null("overlay_dim")
	var lock_icon = button.get_node_or_null("lock_icon")

	
	# Determine button state
	var is_purchased = current_level >= target_level
	var is_next_upgrade = current_level == target_level - 1
	var is_locked = current_level < target_level
	var can_afford = is_next_upgrade and player_money >= data["costs"][target_level-1]
	
	# State 1: Already purchased (show normally, disabled)
	if is_purchased:
		if overlay_dim:
			overlay_dim.visible = true
			overlay_dim.color = "00ff0080"
		if lock_icon:
			lock_icon.visible = false
		if icon:
			icon.modulate = Color(1, 1, 1, 1)  # Full brightness
		button.disabled = true
		button.modulate = Color(0.8, 1, 0.8)  # Slight green tint to show owned
	
	# State 2: Next upgrade - can afford (full brightness, clickable)
	elif is_next_upgrade and can_afford:
		if overlay_dim:
			overlay_dim.visible = false
		if lock_icon:
			lock_icon.visible = false
		if icon:
			icon.modulate = Color(1, 1, 1, 1)  # Full brightness
		button.disabled = false
		button.modulate = Color(1, 1, 1)
	
	# State 3: Next upgrade - cannot afford (dimmed, not clickable)
	elif is_next_upgrade and not can_afford:
		if overlay_dim:
			overlay_dim.visible = true
		if lock_icon:
			lock_icon.visible = false
		if icon:
			icon.modulate = Color(1, 1, 1, 1)
		button.disabled = true
		button.modulate = Color(1, 1, 1)
	
	# State 4: Locked (not next in sequence - show lock icon)
	elif is_locked:
		if overlay_dim:
			overlay_dim.visible = true
		if lock_icon:
			lock_icon.visible = true
		if icon:
			icon.modulate = Color(0.5, 0.5, 0.5, 1)  # Desaturated
		button.disabled = true
		button.modulate = Color(1, 1, 1)

# Optional: Function to add money (for testing)
func add_money(amount: int):
	player_money += amount
	print("Added", amount, "gold. Total:", player_money)
	update_all_buttons()

# Optional: Function to reset all upgrades (for testing)
func reset_upgrades():
	for key in upgrades.keys():
		upgrades[key]["level"] = 0
	update_all_buttons()
