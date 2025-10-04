extends StaticBody2D

@export_category("Weapon Sprites")
@export var flamethrower:PackedScene
@export var harpoon:PackedScene
@export var cannon:PackedScene

@export_category("Balancing")
@export var ftcooldown = 1
@export var hcooldown = 1.5
@export var ccooldown = 2.5
@export var ftdistance = 50
@export var hdistance = 350
@export var cdistance = 1000
@export var weapon_velocity = 100

enum Weapon {FLAMETHROWER, HARPOON, CANNON}

var weapon = Weapon.HARPOON
var weapon_on_cooldown = false
var distance = hdistance
var cooldown = hcooldown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$weapon_cooldown.start(cooldown)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cycle_weapon"):
		weapon = (weapon + 1) % Weapon.size() as Weapon
	if Input.is_action_just_pressed("fire_weapon"):
		if (!weapon_on_cooldown):
			fire()
			
func fire():
	var instance
	match weapon:
		Weapon.FLAMETHROWER:
			instance = flamethrower.instantiate()
		Weapon.HARPOON:
			instance = harpoon.instantiate()
			print("harpoon spawns")
		Weapon.CANNON:
			instance = cannon.instantiate()
		_:
			printerr("How did we get here")
	instance.global_position = global_position
	instance.player = self
	get_tree().current_scene.get_node("Game_Manager").add_child(instance)
	weapon_on_cooldown = true

func _on_weapon_cooldown_timeout() -> void:
	print("weapon cooldown ended")
	weapon_on_cooldown = false
