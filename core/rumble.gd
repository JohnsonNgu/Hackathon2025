extends Area2D

@export_category("Weapon Sprites")
@export var flamethrower:PackedScene
@export var harpoon:PackedScene
@export var cannon:PackedScene

@export_category("Balancing")
@export var health = 15
@export var weapon_velocity = 100

enum Weapon {FLAMETHROWER, HARPOON, CANNON}

var weapon = Weapon.HARPOON
var weapon_on_cooldown = false

var changes = 1 #placeholder for shop editions and whatnot to edit cds and such

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cycle_weapon"):
		cycle_weapon()
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
		Weapon.CANNON:
			instance = cannon.instantiate()
		_:
			printerr("How did we get here")
	instance.global_position = global_position
	instance.player = self
	get_tree().current_scene.get_node("Game_Manager").add_child(instance)
	$weapon_cooldown.start(instance.cooldown)
	weapon_on_cooldown = true
	
func cycle_weapon():
	weapon = (weapon + 1) % Weapon.size() as Weapon
	print("Cylce to ", weapon)
	#match weapon:
		#Weapon.FLAMETHROWER:
			#cooldown = ftcooldown * changes
		#Weapon.HARPOON:
			#cooldown = hcooldown * changes
		#Weapon.CANNON:
			#cooldown = ccooldown * changes
		#_:
			#printerr("How did we get here")

func _on_weapon_cooldown_timeout() -> void:
	weapon_on_cooldown = false
