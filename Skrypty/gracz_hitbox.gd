extends Area2D

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("area_entered", _on_area_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		get_parent().take_damage(body.damage)


func _on_area_entered(area: Node) -> void:
	if area.is_in_group("enemy_projectile"):
		get_parent().take_damage(area.damage)
		
	elif area.is_in_group("dropped_item"):
		if player_inventory.add_item(area.item):
			area.queue_free()
		
	elif area.is_in_group("teleport"):
		global.emit_signal("change_scene", area.destination)
		global.emit_signal("update_ui", area.is_base)


func _process(delta: float) -> void:
	pass
