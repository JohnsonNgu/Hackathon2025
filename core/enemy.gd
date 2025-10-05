extends Node2D

class_name Enemy

@export var health = 5
@export var speed = 100
@export var direction = Vector2.RIGHT
@export var money = 5
var velocity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = speed * direction
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += velocity * delta
	pass

func _on_hurtbox_area_entered(area: Area2D) -> void:
	velocity = Vector2.ZERO

func take_damage(damage:int):
	health = health - damage
	if (health <= 0): die()
	
func die():
	queue_free()
