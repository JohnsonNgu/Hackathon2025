extends Node2D

class_name Enemy

signal die(enemy:Node2D)

@export var health = 5
@export var speed = 100
@export var direction = Vector2.RIGHT
@export var gold_value = 5
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
	if (health <= 0): health_depleted()
	
func health_depleted():
	emit_signal("die", self)
	queue_free()
