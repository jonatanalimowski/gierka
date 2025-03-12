extends Area2D
var is_taking_damage = false

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	connect("area_entered", _on_area_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and not is_taking_damage:
		is_taking_damage = true
		take_damage_loop(body)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("enemy"):
		is_taking_damage = false  # Zatrzymanie obrażeń


func take_damage_loop(body: Node) -> void:
	while is_taking_damage and is_instance_valid(body):
		get_parent().take_damage(body.damage)
		await get_tree().create_timer(1.0).timeout


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
