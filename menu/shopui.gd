extends Node

@onready var active_grid = $GUI/VBoxContainer/HBoxContainer/Active/GridContainer
@onready var passive_grid = $GUI/VBoxContainer/HBoxContainer/Passive/GridContainer
@onready var gold_label = $GUI/VBoxContainer/HBoxContainer2/Gold

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var active_keys = ["flamethrower", "harpoon", "cannon"]
	var passive_keys = ["equilizer", "shield", "mines"]
	
	# Setup upgrade buttons
	setup_upgrade_column(active_grid, active_keys, "active")
	setup_upgrade_column(passive_grid, passive_keys, "passive")
	
	# Connect to Shop signals for reactive updates
	Shop.money_changed.connect(_on_money_changed)
	Shop.upgrade_purchased.connect(_on_upgrade_purchased)
	
	# Initial UI update
	update_ui()

func _process(delta: float) -> void:
	# Close shop with Escape key
	if Input.is_action_just_pressed("escape"):
		self.visible = false
		get_tree().paused = false

func setup_upgrade_column(container: HBoxContainer, keys: Array, type: String):
	for i in range(keys.size()):
		var key = keys[i]
		var weapon_container = container.get_child(i)
		
		var count = 1
		for button in weapon_container.get_children():
			# Store metadata
			button.set_meta("upgrade_key", key)
			button.set_meta("upgrade_level", count)
			button.set_meta("type", type)
			
			# Connect signal
			button.pressed.connect(_on_upgrade_button_pressed.bind(button))
			
			# Setup button visuals
			setup_button_visuals(button, key, count)
			
			count += 1

func setup_button_visuals(button: Button, key: String, level: int):
	var icon = button.get_node_or_null("icon")
	var overlay_dim = button.get_node_or_null("overlay_dim")
	var lock_icon = button.get_node_or_null("lock_icon")
	var tooltip = null
	
	if button.get_meta("type") == "active":
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
		if label_tooltip:
			var upgrade_data = Shop.get_upgrade_data(key)
			if upgrade_data.has("description"):
				label_tooltip.text = upgrade_data["description"][level - 1]

func _on_upgrade_button_pressed(button: Button):
	var key = button.get_meta("upgrade_key")
	var target_level = button.get_meta("upgrade_level")
	
	# Attempt purchase through Shop singleton
	# All validation and money deduction happens in Shop
	Shop.purchase_upgrade(key, target_level)

func _on_money_changed(new_amount: int):
	# Automatically called when Shop.player_money changes
	gold_label.text = "Gold: " + str(new_amount)
	update_all_buttons()

func _on_upgrade_purchased(upgrade_key: String, new_level: int):
	# Automatically called when an upgrade is purchased
	update_all_buttons()

func update_ui():
	# Manually refresh the entire UI from Shop data
	gold_label.text = "Gold: " + str(Shop.player_money)
	update_all_buttons()

func update_all_buttons():
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
	var data = Shop.get_upgrade_data(key)
	var current_level = data["level"]
	
	var icon = button.get_node_or_null("icon")
	var overlay_dim = button.get_node_or_null("overlay_dim")
	var lock_icon = button.get_node_or_null("lock_icon")
	
	# Determine button state based on Shop data
	var is_purchased = current_level >= target_level
	var is_next_upgrade = current_level == target_level - 1
	var is_locked = current_level < target_level
	var can_afford = is_next_upgrade and Shop.player_money >= data["costs"][target_level - 1]
	
	# State 1: Already purchased (green overlay, disabled)
	if is_purchased:
		if overlay_dim:
			overlay_dim.visible = true
			overlay_dim.color = Color("00ff0080")
		if lock_icon:
			lock_icon.visible = false
		if icon:
			icon.modulate = Color(1, 1, 1, 1)
		button.disabled = true
		button.modulate = Color(0.8, 1, 0.8)
	
	# State 2: Next upgrade - can afford (full brightness, clickable)
	elif is_next_upgrade and can_afford:
		if overlay_dim:
			overlay_dim.visible = false
		if lock_icon:
			lock_icon.visible = false
		if icon:
			icon.modulate = Color(1, 1, 1, 1)
		button.disabled = false
		button.modulate = Color(1, 1, 1)
	
	# State 3: Next upgrade - cannot afford (dimmed, disabled)
	elif is_next_upgrade and not can_afford:
		if overlay_dim:
			overlay_dim.visible = true
		if lock_icon:
			lock_icon.visible = false
		if icon:
			icon.modulate = Color(1, 1, 1, 1)
		button.disabled = true
		button.modulate = Color(1, 1, 1)
	
	# State 4: Locked (lock icon, desaturated, disabled)
	elif is_locked:
		if overlay_dim:
			overlay_dim.visible = true
		if lock_icon:
			lock_icon.visible = true
		if icon:
			icon.modulate = Color(0.5, 0.5, 0.5, 1)
		button.disabled = true
		button.modulate = Color(1, 1, 1)
