extends Node2D

@export var small_enemy:PackedScene
@export var med_enemy:PackedScene
@export var large_enemy:PackedScene

enum Enemy_Type {SMALL, MEDIUM, LARGE}
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
			scene = small_enemy.instantiate()
		1:
			scene = med_enemy.instantiate()
		2:
			scene = large_enemy.instantiate()
		_:
			printerr("ERROR: Incorrect enemy type random")
	var orientation = randi() % 2
	if (orientation == 0):
		scene.global_position = Vector2(-30, GROUND_HEIGHT)
	else:
		scene.global_position = Vector2(1310, GROUND_HEIGHT)
		scene.direction = Vector2.LEFT
		scene.get_node("Sprite2D").flip_v = true
		#scene.get_node("Sprite2D").flip_h = true
		scene.rotation = PI
	get_tree().current_scene.get_node("Game_Manager").add_child(scene)
