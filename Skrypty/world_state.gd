extends Node
var current_map = "base_node"
var current_scene
var main_node
var dropped_items = []
var buildings = []
var enemies = []
var base_state = {
	"dropped_items":null,
	"enemies": null,
	"buildings": null,
}

var expedition_state = {
	"dropped_items":null,
	"enemies": null,
	"buildings": null,
}

var state = {
	"dropped_items": null,
	"enemies": null,
	"buildings": null,
}

func save_world_state():
	print("SAVE MAP", current_map)
	print(current_map) 
	dropped_items = []
	buildings = []
	enemies = []

	# Zapis upuszczonych przedmiotów
	for item in get_tree().get_nodes_in_group("dropped_item"):
		var data = {
			"scene_path": "res://Scenki/dropped_item.tscn",
			"pos": item.global_position,
			"item_data": item.item,
			"texture": item.texture
		}
		dropped_items.append(data)

	# Zapis budynków
	for building in get_tree().get_nodes_in_group("building"):
		var data: Dictionary
		if building.building_data.has_inventory == false:
			data = {
				"scene_path": building.building_data.building_scene,
				"pos": building.global_position,
				"has_inventory": false
			}
		else:
			data = {
				"scene_path": building.building_data.building_scene,
				"pos": building.global_position,
				"has_inventory": true,
				"inventory": building.item_container.inv_array
			}
		buildings.append(data)


	# Zapis przeciwników
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var data = {
			"scene_path": "res://Scenki/slime.tscn",
			"pos": enemy.global_position,
			"enemy_health": enemy.health
		}
		enemies.append(data)
	
	
	#zapisanie do odpowiedniego slownika
	state["enemies"] = enemies
	state["dropped_items"] = dropped_items
	state["buildings"] = buildings
	if current_map == "expedition_node":
		expedition_state = state
	else:
		base_state = state



#wczytanie stanu świata instancjonowanie obiektu na podstawie zapisanych danych
func load_world_state():
	print("LOAD_MAP", current_map) 
	print(current_map) 
	if current_scene == null:
		print("loading error, no currentscene")
		return
	
	if current_map == "expedition_node":
		state = expedition_state
	else:
		state = base_state
	enemies = state["enemies"]
	dropped_items = state["dropped_items"]
	buildings = state["buildings"]
	
	#wczytanie upuszczonych przedmiotów
	if dropped_items:
		for data in dropped_items:
			var scene = load(data["scene_path"]).instantiate()
			scene.global_position = data["pos"]
			scene.item = data["item_data"]
			scene.texture = data["texture"]
			current_scene.add_child(scene)

	#wczytanie budynków
	if buildings:
		for data in buildings:
			var scene = data["scene_path"].instantiate()
			scene.global_position = data["pos"]
			if data["has_inventory"]:
				scene.loaded_inv_array = data["inventory"]
			current_scene.add_child(scene)

	#wczytanie przeciwników
	if enemies:
		for data in enemies:
			var scene = load(data["scene_path"]).instantiate()
			scene.global_position = data["pos"]
			scene.health = data["enemy_health"]
			current_scene.add_child(scene)


func set_current_scene(scene = null):
	if scene == null: #pozostalosci po wczesniejszej implementacji, moze sie przydac
		main_node = get_node("/root/Node2D") 
		if main_node:
			current_scene = main_node.current_scene_container
			if current_scene and current_scene.get_child_count() > 0:
				current_map = current_scene.get_child(0).name
		else:
			print("main node not found")
	
	else: #przewaznie tylko to jest wykonywane
		current_scene = scene
		current_map = current_scene.name


func clear_instanced_objects():
	for node in get_tree().get_nodes_in_group("cleared_on_scene_change"):
		node.queue_free()
