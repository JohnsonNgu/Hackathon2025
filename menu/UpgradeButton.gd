extends Node

func _on_mouse_entered():
	if (get_meta("type") == "active"):
		get_node_or_null("tooltip_active").visible = true
	elif (get_meta("type") == "passive"):
		get_node_or_null("tooltip_passive").visible = true

func _on_mouse_exited():
	if (get_meta("type") == "active"):
		get_node_or_null("tooltip_active").visible = false
	elif (get_meta("type") == "passive"):
		get_node_or_null("tooltip_passive").visible = false

func _on_overlay_dim_mouse_entered() -> void:
	_on_mouse_entered()

func _on_overlay_dim_mouse_exited() -> void:
	_on_mouse_exited()
