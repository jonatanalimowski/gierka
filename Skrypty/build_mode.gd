extends Node2D

var ghost_building = null
var world_building = null
@onready var tilemap = get_tree().get_root().find_child("TileMapLayer", true, false)
@onready var world = get_tree().get_root().find_child("CurrentScene", true, false).get_child(0)
var collidable_tiles = [Vector2i(1,1), Vector2i(1,2), Vector2i(2,1), Vector2i(3,2)]
var can_be_placed = false
var building_recipe

func start_building_mode(recipe):
	building_recipe = recipe
	if ghost_building:
		cancel_building_mode()
	ghost_building = recipe.building_scene.instantiate()
	world_building = recipe.building_scene.instantiate()
	
	ghost_building.toggle_collisions()
	ghost_building.is_active = false
	ghost_building.modulate = Color(1, 1, 1, 0.5)
	add_child(ghost_building)


func cancel_building_mode():
	if ghost_building:
		ghost_building.queue_free()
		ghost_building = null


func _process(delta: float) -> void:
	if ghost_building:
		var target_pos = get_global_mouse_position()
		target_pos = snapped(target_pos, Vector2(64, 64))
		ghost_building.global_position = target_pos
		
		if check_for_space(target_pos):
			ghost_building.modulate = Color(0, 5, 0, 0.5)
			can_be_placed = true
		else:
			ghost_building.modulate = Color(5, 0, 0, 0.5)
			can_be_placed = false


func _input(event):
	if can_be_placed and ghost_building:
		
		if event.is_action_pressed("shoot"):
			place_building()
			if not building_recipe: #odejmowanie itemkow z ekwipunku gracza
				return
			for item_name in building_recipe.materials_for_construction:
				player_inventory.remove_amount_from_inv(item_name, building_recipe.materials_for_construction[item_name])
					
		elif event.is_action_pressed("right_mouse"):
			cancel_building_mode()


func place_building():
	var pos = Vector2(0,0)
	if ghost_building:
		pos = ghost_building.position
	cancel_building_mode()
	if world_building:
		world_building.position = pos
		if world == null:
			world = get_tree().get_root().find_child("CurrentScene", true, false).get_child(0)
		world.add_child(world_building)


func check_for_space(pos):
	if not tilemap:
		tilemap = get_tree().get_root().find_child("TileMapLayer", true, false)
		return false
	else:	
		pos = tilemap.local_to_map(pos)
		if tilemap.get_cell_atlas_coords(pos) not in collidable_tiles:
			return true
		return false
