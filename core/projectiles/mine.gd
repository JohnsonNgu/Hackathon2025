extends Node2D

@export var stun_duration = 1.5
var aoe = false

const ENEMY_LAYER_MASK = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_hitbox_area_entered(area: Area2D) -> void:
	area.get_parent().stun(stun_duration)
	if (aoe):
		var aoe_shape := get_node("aoe/CollisionShape2D").shape as CircleShape2D
		
		var aoe_transform := Transform2D.IDENTITY
		aoe_transform.origin = global_position
		
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = aoe_shape
		query.transform = aoe_transform
		query.collision_mask = ENEMY_LAYER_MASK
		query.collide_with_areas = true
		
		var results = space_state.intersect_shape(query)
		
		for result in results:
			var target = result.collider
			target.get_parent().stun(stun_duration)
	queue_free()
