extends Node

# Upgrade data (just like before)
var upgrades = {
	"flamethrower": {"level": 1, "max_level": 3, "costs": [100, 200, 500], "description": ["Costs: 100 Gold\nRumble’s Trusty Fire Splitter, great for getting them off of you!", "Costs: 200 Gold\nRumble uses double the fuel to increase the size of his fire! (Slightly more dmg &  Larger radius)", "Costs: 500 Gold\nThe metal is so hot it created an aura of fire! (Flame ring surrounds Rumble's mech)"]},
	"harpoon": {"level": 1, "max_level": 3, "costs": [100, 200, 500], "description": ["Costs: 100 Gold\nRumble Shoot a mid-range missile like harpoon that hits the first enemy it collides with", "Costs 200 Gold\nRumble modifies his harpoon to be ready and loaded faster, while polishing the tips (increases attack speed and dmg)", "Costs 500 Gold\nIt’s like 2 birds with 1 stone, except its monsters, and with a harpoon (Adds Pierce to hit 2 targets"]},
	"cannon": {"level": 0, "max_level": 3, "costs": [100, 200, 500], "description": ["Costs: 100 Gold\nRumble ‘borrowed’ Tristana’s gun and uses its long range to take down foes", "Costs: 200 Gold\nRumble Remembered to turn the safety off, making Tristana’s cannon fire much faster (Increases attack speed)", "Costs: 500 Gold\nRumbles uses Tristana’s bombs instead, doing splash dmg to nearby enemies (Hits do Splash Dmg)"]},
	"equilizer": {"level": 0, "max_level": 3, "costs": [100, 200, 500], "description": ["Costs: 100 Gold\nRumble periodically launches missiles from his mech, damaging any enemies (every 15 seconds, fire 4 missiles, 2 left and 2 right)", "Costs: 200 Gold\nRumble adds a special propane mix to his missiles (increases damage)", "Costs: 500 Gold\nTime for a Bandle City Beatdown! (Add a missile to the left and right)"]},
	"shield": {"level": 0, "max_level": 3, "costs": [100, 200, 500], "description": ["Costs: 100 Gold\nRumble defies the laws of physics and generates a shield after not taking damage (gain a shield after not taking damage for 15 seconds)", "Costs: 200 Gold\nRumble fixes one screw to make his shield more stable (Increases the shielding Amount)", "Costs: 500 Gold\n Why are you hitting yourself? Why are you hitting yourself? (Adds reflective dmg to the shield)"]},
	"mines": {"level": 0, "max_level": 3, "costs": [100, 200, 500], "description": ["Costs: 100 Gold\nTeemo wants Rumble to believe hes winning, but knows he’ll be overunned, so he gave him some shock mines without him noticing (mines are placed on the field that stun enemies)", "Costs 200: Gold\nTeemo secretly upgrades the mines to make them Shocking(adds stun duration)", "Costs 500: Gold\n Teemo brings out the mines from his bandle’s bag, they are volitile (mines do Splash Dmg)"]},
}

signal money_changed(new_amount: int)
signal upgrade_purchased(upgrade_key: String, new_level: int)

var player_money: int = 100:
	set(value):
		player_money = value
		money_changed.emit(player_money)

func add_money(amount: int) -> void:
	player_money += amount

func can_afford_upgrade(upgrade_key: String, target_level: int) -> bool:
	if not upgrades.has(upgrade_key):
		return false
	
	var data = upgrades[upgrade_key]
	if target_level < 1 or target_level > data["max_level"]:
		return false
	
	var cost = data["costs"][target_level - 1]
	return player_money >= cost

func is_upgrade_available(upgrade_key: String, target_level: int) -> bool:
	if not upgrades.has(upgrade_key):
		return false
	
	var data = upgrades[upgrade_key]
	return data["level"] == target_level - 1

func purchase_upgrade(upgrade_key: String, target_level: int) -> bool:
	if not upgrades.has(upgrade_key):
		push_error("Invalid upgrade key: " + upgrade_key)
		return false
	
	var data = upgrades[upgrade_key]
	
	# Validation checks
	if data["level"] >= target_level:
		print(upgrade_key, "level", target_level, "already purchased!")
		return false
	
	if data["level"] != target_level - 1:
		print("Must purchase previous upgrades first!")
		return false
	
	if data["level"] >= data["max_level"]:
		print(upgrade_key, "is already fully upgraded!")
		return false
	
	var cost = data["costs"][target_level - 1]
	
	if player_money < cost:
		print("Not enough money for", upgrade_key, "- Need:", cost, "Have:", player_money)
		return false
	
	# Execute purchase
	player_money -= cost
	data["level"] += 1
	
	print("Upgraded", upgrade_key, "to level", data["level"], "for", cost, "gold")
	print("Remaining money:", player_money)
	
	upgrade_purchased.emit(upgrade_key, data["level"])
	return true

func get_upgrade_level(upgrade_key: String) -> int:
	if upgrades.has(upgrade_key):
		return upgrades[upgrade_key]["level"]
	return 0

func get_upgrade_data(upgrade_key: String) -> Dictionary:
	if upgrades.has(upgrade_key):
		return upgrades[upgrade_key]
	return {}

func reset_upgrades() -> void:
	for key in upgrades.keys():
		upgrades[key]["level"] = 0
