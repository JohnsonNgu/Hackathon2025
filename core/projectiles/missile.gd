extends Projectile

var random_pos = RandomNumberGenerator.new()

func _ready():
	self.rotation_degrees = 270.0
	await ready
	get_node("aoe/CollisionShape2D").shape.radius = aoe_radius
	velocity = direction.rotated(rotation) * initial_speed
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	self.rotation_degrees = 90.0
	velocity = direction.rotated(rotation) * initial_speed
	position.x = random_pos.randf_range(0.0,1280.0)
