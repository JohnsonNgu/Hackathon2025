extends Node2D

@export var void_fish:PackedScene
@export var voidling:PackedScene
@export var void_grub:PackedScene
@export var void_scuttle:PackedScene
@export var void_red:PackedScene
@export var void_blue:PackedScene

var player_money
enum Enemy_Type{FISH, VOIDLING, GRUB, SCUTTLE, RED, BLUE}
var voidling_count = 0

const GROUND_HEIGHT = 445

var shop_scene = preload("res://menu/shop.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shop_scene = shop_scene.instantiate()
	add_child(shop_scene)
	shop_scene.visible = false
	shop_scene.z_index = 99
	shop_scene.process_mode = PROCESS_MODE_ALWAYS
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("show_shop"):
		shop_scene.visible = true
		get_tree().paused = true
	#if Input.is_action_just_pressed("escape") and !shop_scene.visible:
		#get_tree().paused = true
	#if Input.is


func _on_enemy_spawn_timeout() -> void:
	spawn_enemy()
	
func spawn_enemy():
	var type = randi() % Enemy_Type.size()
	var scene
	match type:
		0:
			scene = void_fish.instantiate()
		1:
			voidling_count = 0
			spawn_voidling()
			return
		2:
			scene = void_grub.instantiate()
		3:
			scene = void_scuttle.instantiate()
		4:
			scene = void_red.instantiate()
		5:
			scene = void_blue.instantiate()
		_:
			printerr("ERROR: Incorrect enemy type random")
	scene = decide_side(scene)
	get_tree().current_scene.get_node("Game_Manager").add_child(scene)
	
func decide_side(scene:Node) -> Node:
	var orientation = randi() % 2
	if (orientation == 0):
		scene.global_position = Vector2(-30, GROUND_HEIGHT)
	else:
		scene.global_position = Vector2(1310, GROUND_HEIGHT)
		scene.direction = Vector2.LEFT
		scene.get_node("Sprite2D").flip_v = true
		#scene.get_node("Sprite2D").flip_h = true
		scene.rotation = PI
	return scene
	
func spawn_voidling():
	var scene = voidling.instantiate()
	scene = decide_side(scene)
	for i in range(3):
		print("its voiding time then he voided all over the place")
		var clone = scene.duplicate(DUPLICATE_USE_INSTANTIATION)
		get_tree().current_scene.get_node("Game_Manager").add_child(clone)
		await get_tree().create_timer(0.6).timeout
	
