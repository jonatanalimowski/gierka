extends Node

signal player_health_changed()
signal change_scene(path)
signal update_ui(is_base)
signal player_leveled_up
signal player_xp_changed
signal player_stat_update
signal toggle_crafting_ui(recipes)
signal craft_item(recipe)
signal close_building_ui
signal open_chest_ui(item_container_scene)
signal inventory_updated(item_container_scene)
signal set_tilemap
signal start_world_generation
signal world_generation_finished
signal map_generated(tilemap)
signal player_pos_set(pos)
signal map_data_ready(data)
signal player_spawn_ready(pos)
signal toolbar_chosen_item_changed(item)
signal player_dashed(dash_cooldown)
signal time_updated(day, hour, minute)

var player_current_health: int = 100
var player_max_health: int = 100
var player_damage: int = 50
var player_speed = 300
var player_level: int = 1
var player_armor = 5
var player_money: int = 0
var player_experience: int = 0
var new_level_threshhold: int = 10
var player_spawn: Vector2
var enemy_entities_alive: int = 0
var available_buildings = [
	preload("res://Resources/Buildings/crafting_station.tres"),
	preload("res://Resources/Buildings/chest.tres")
]

func _ready() -> void:
	player_inventory.item_equipped.connect(item_equipped)
	player_inventory.item_unequipped.connect(item_unequipped)


func add_xp(amount):
	player_experience += amount
	if player_experience >= new_level_threshhold:
		level_up()
	emit_signal("player_xp_changed")


func level_up():
	player_experience -= new_level_threshhold
	new_level_threshhold *= 1.3
	player_level += 1
	emit_signal("player_leveled_up")
	emit_signal("player_stat_update")


func change_sprite_color(par, is_entity_static = false):
	var sprite = get_sprite(par)
	if is_instance_valid(sprite):
		if is_entity_static == false:
			sprite.modulate = Color(5, 0, 0)  # Flash red
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(sprite):
				var tween = create_tween()
				tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.15)  # Smooth fade back
				tween.play()
		else:
			sprite.modulate = Color(0.5, 0.5, 0.5)  # Flash dark
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(sprite):
				var tween = create_tween()
				tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.15)  # Smooth fade back
				tween.play()


func get_sprite(node: Node): #funkcja od  macka
	if not node:
		return null
	
	# If the node itself is a Sprite2D, return it
	if node is Sprite2D or node is AnimatedSprite2D:
		return node
	
	# Check children recursively
	for child in node.get_children():
		var sprite = get_sprite(child)
		if sprite:
			return sprite  # Stop at the first found Sprite2D

	return null  # No Sprite2D found


func item_equipped(item):
	if item:
		player_damage += item.damage
		player_max_health += item.health
		player_current_health += item.health
		player_armor += item.armor
		player_speed += item.speed
		emit_signal("player_stat_update")


func item_unequipped(item):
	if item:
		player_damage -= item.damage
		player_max_health -= item.health
		player_current_health -= item.health
		player_armor -= item.armor
		player_speed -= item.speed
		emit_signal("player_stat_update")


func is_area_free(pos: Vector2) -> bool:
	var space_state = get_tree().root.get_world_2d().direct_space_state
	if space_state == null:
		return false 
	
	var circle_shape = CircleShape2D.new() #tworzy kolko a pozniej sprawdza czy jest z nim kolizja
	circle_shape.radius = 4 

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = circle_shape
	query.transform = Transform2D(0, pos)
	query.collide_with_bodies = true
	query.collide_with_areas = true

	var result = space_state.intersect_shape(query)
	return result.size() == 0
