extends Area2D

@export_category("Weapon Sprites")
@export var flamethrower:PackedScene
@export var harpoon:PackedScene
@export var cannon:PackedScene

@export_category("Balancing")
@export var initial_health = 15
@export var weapon_velocity = 100

enum Weapon {FLAMETHROWER, HARPOON, CANNON}

signal lose_game

var weapon = Weapon.HARPOON
var weapon_on_cooldown = false
var health = initial_health

var changes = 1 #placeholder for shop editions and whatnot to edit cds and such

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Shop.upgrade_purchased.connect(_on_upgrade_purchased)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cycle_weapon"):
		cycle_weapon()
	if Input.is_action_pressed("fire_weapon"):
		if (!weapon_on_cooldown):
			fire()
			
func fire(type = weapon):
	var instance
	var attack_speed = 1
	var damage = 0
	match type:
		Weapon.FLAMETHROWER:
			instance = flamethrower.instantiate()
			if (Shop.get_upgrade_level(Weapon.keys()[weapon].to_lower()) >= 2):
				instance.damage += .25
		Weapon.HARPOON:
			instance = harpoon.instantiate()
			if (Shop.get_upgrade_level(Weapon.keys()[weapon].to_lower()) >= 2):
				instance.damage += 2
				attack_speed = 0.75
			if (Shop.get_upgrade_level(Weapon.keys()[weapon].to_lower()) == 3):
				instance.pierce += 1
		Weapon.CANNON:
			instance = cannon.instantiate()
			if (Shop.get_upgrade_level(Weapon.keys()[weapon].to_lower()) >= 2):
				attack_speed = 0.5
			if (Shop.get_upgrade_level(Weapon.keys()[weapon].to_lower()) == 3):
				instance.aoe_radius = 50
				instance.get_node("Sprite2D").frame = 1
		_:
			printerr("How did we get here")
	instance.global_position = global_position
	instance.player = self
	get_tree().current_scene.get_node("Game_Manager").add_child(instance)
	$weapon_cooldown.start(instance.cooldown * attack_speed)
	weapon_on_cooldown = true
	
func cycle_weapon():
	weapon = (weapon + 1) % Weapon.size() as Weapon
	if (Shop.get_upgrade_level(Weapon.keys()[weapon].to_lower()) == 0):
		cycle_weapon()

func _on_weapon_cooldown_timeout() -> void:
	weapon_on_cooldown = false


func _on_flame_ring_timeout() -> void:
	var instance = flamethrower.instantiate()
	var instance2 = flamethrower.instantiate()
	instance.global_position = global_position
	instance2.global_position = global_position
	instance.damage += 2
	instance2.damage += 2
	instance.player_fired = false
	instance2.player_fired = false
	instance2.rotation = PI
	instance.player = self
	instance2.player = self
	get_tree().current_scene.get_node("Game_Manager").add_child(instance)
	get_tree().current_scene.get_node("Game_Manager").add_child(instance2)
	
func _on_upgrade_purchased(key, level):
	if (key == "flamethrower" and level == 3):
		$flame_ring.start()
	pass


func _on_game_manager_enemy_hit(enemy: Node2D) -> void:
	health -= enemy.damage
	if (health <= 0):
		emit_signal("lose_game")


func _on_lose_game() -> void:
	get_tree().change_scene_to_file("res://menu/game_over.tscn")
