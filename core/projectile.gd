extends Area2D

class_name projectile

@export var initial_speed = 250
@export var distance = 350
@export var player:StaticBody2D
var direction = Vector2.RIGHT


var velocity
var current_distance = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await ready
	look_at(get_global_mouse_position())
	velocity = direction.rotated(rotation) * initial_speed
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += velocity * delta
	current_distance = player.global_position.distance_to(position)
	if (current_distance > distance):
		queue_free()
	pass
