extends Node2D

class_name Enemy

signal die(enemy:Node2D)
signal attack(enemy:Node2D)

@export var health = 5
@export var speed = 100
@export var direction = Vector2.RIGHT
@export var gold_value = 5
@export var damage = 5.0
var velocity
var stunned = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = speed * direction
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (!stunned):
		position += velocity * delta
	pass

func _on_hurtbox_area_entered(area: Area2D) -> void:
	velocity = Vector2.ZERO
	$attack_timer.start()

func take_damage(damage:float):
	health = health - damage
	if (health <= 0): health_depleted()
	
func health_depleted():
	emit_signal("die", self)
	queue_free()

func stun(stun_duration):
	$stun_timer.start(stun_duration)
	print("stunned for ", stun_duration)
	stunned = true

func _on_attack_timer_timeout() -> void:
	emit_signal("attack", self)


func _on_stun_timer_timeout() -> void:
	stunned = false
	print ("not stunned")
