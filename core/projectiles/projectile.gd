extends Node2D

class_name Projectile

@export var initial_speed = 250
@export var distance = 350
@export var player:Area2D
@export var damage = 3.0
@export var cooldown = 2.0
@export var aoe_radius = .01
@export var pierce = 1
var direction = Vector2.RIGHT
var player_fired = true

const ENEMY_LAYER_MASK = 2
var velocity
var current_distance = 0
var hit_enemies = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await ready
	get_node("aoe/CollisionShape2D").shape.radius = aoe_radius
	if (player_fired):
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
	
func get_damage() -> int:
	return damage


func _on_hitbox_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent() as Enemy
	hit(enemy)

func hit(enemy: Enemy):
	for target in hit_enemies:
		if (target == enemy):
			return
	enemy.take_damage(damage)
	hit_enemies.append(enemy)
	if (aoe_radius > 1):
		var aoe_shape := CircleShape2D.new()
		aoe_shape.radius = aoe_radius
		
		var aoe_transform := Transform2D.IDENTITY
		aoe_transform.origin = global_position
		
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = aoe_shape
		query.transform = aoe_transform
		query.collision_mask = ENEMY_LAYER_MASK
		
		var results = space_state.intersect_shape(query)
		
		for result in results:
			var target = result.collider
			target.take_damage(damage)
		
	pierce -= 1
	if (pierce <= 0):
		queue_free()
