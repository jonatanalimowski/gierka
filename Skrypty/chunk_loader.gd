extends Node
var static_entities_data = [
	{"scene": preload("res://Scenki/normal_rock.tscn"), "chance": 512, "biome": "Forest"},
	{"scene": preload("res://Scenki/normal_tree.tscn"), "chance": 512, "biome": "Forest"},
	{"scene": preload("res://Scenki/normal_bush.tscn"), "chance": 256, "biome": "Forest"}
]

var seed = 0
var chunk_size = Vector2i(32, 32)
var saved_chunks = []
var loaded_chunks = []
var world_size: Vector2i
var tilemap: TileMapLayer
var last_chunk_visited = Vector2i(-100,-100)
var generator = WorldGenerator.new()
var player_current_biome: String
var rng = RandomNumberGenerator.new()
var biome_dict = { #currently unused
	Vector2i(3, 1): "Forest",
	Vector2i(3, 3): "Dunes",
	Vector2i(2, 2): "Tundra"
}
var instantiated_static_entities: Array = []


func set_chunk_loader_seed(seed):
	generator.initialise_noise_generator(seed)
	rng.seed = seed


func save_new_chunk(chunk_x, chunk_y): 
	if tilemap:
		
		var offset_vector = Vector2i(chunk_size.x * chunk_x, chunk_size.y * chunk_y)
		generator.generate_map_array_from_seed(chunk_size, offset_vector)
		var chunk_tiles_array = generator.change_numbers_to_tile_vectors(generator.world_data)
		#assigns a biome to a chunk; this is really not a good way to do this xd
		var forest_tiles = 0
		var dune_tiles = 0
		var tundra_tiles = 0
		for x in range(chunk_tiles_array.size()):
			forest_tiles += chunk_tiles_array[x].count(Vector2i(3, 1))
			dune_tiles += chunk_tiles_array[x].count(Vector2i(3, 3))
			tundra_tiles += chunk_tiles_array[x].count(Vector2i(2, 2))
		
		var biggest_value = max(forest_tiles, dune_tiles, tundra_tiles)
		var current_biome: String
		if forest_tiles == biggest_value:
			current_biome = "Forest"
		elif dune_tiles == biggest_value:
			current_biome = "Dunes"
		elif tundra_tiles == biggest_value:
			current_biome = "Tundra"
		else:
			current_biome = "No Biome"
		
		var generated_static_entities = generate_static_entities(offset_vector, chunk_tiles_array.duplicate(), current_biome)
		#finalises generation; creates new dictionary with generated data
		var chunk_data = {
			"chunk_pos": Vector2i(chunk_x, chunk_y),
			"chunk_tiles": chunk_tiles_array,
			"biome": current_biome,
			"generated_entities": generated_static_entities
		}
		saved_chunks.append(chunk_data)
		return chunk_data


func unload_chunk(chunk_x, chunk_y):
	if Vector2i(chunk_x, chunk_y) in loaded_chunks:
		if tilemap:
			var current_chunk_data = []
			for chunk_data in saved_chunks:
				if chunk_data["chunk_pos"] == Vector2i(chunk_x, chunk_y):
					current_chunk_data = chunk_data
			
			#sets world tilemap tiles to no tile
			if current_chunk_data:
				for x in range(current_chunk_data["chunk_tiles"].size()):
					for y in range(current_chunk_data["chunk_tiles"][x].size()):
						tilemap.set_cell(Vector2i(chunk_x*chunk_size.x + x, chunk_y*chunk_size.y + y), 0, Vector2i(-1, -1))
			
			#frees static entities
			for entity_data in instantiated_static_entities.duplicate():
				if entity_data["chunk_vector"].x == chunk_x and entity_data["chunk_vector"].y == chunk_y:
					instantiated_static_entities.erase(entity_data)
					if is_instance_valid(entity_data["instance_ref"]):
						entity_data["instance_ref"].queue_free()
					else:
						for chunk_entity_data in current_chunk_data["generated_entities"]: #if entity was destroyed it will not be generated again
							if chunk_entity_data["id"] == entity_data["entity_id"]:
								current_chunk_data["generated_entities"].erase(chunk_entity_data)
			loaded_chunks.erase(Vector2i(chunk_x, chunk_y))


func load_chunk(chunk_x, chunk_y):
	if Vector2i(chunk_x, chunk_y) not in loaded_chunks:
		var current_chunk_data = []
		var was_chunk_generated = false
		if tilemap:
			#if chunk was generated uses it to load tilemap, if not generates new chunk
			for chunk_data in saved_chunks:
				if chunk_data["chunk_pos"] == Vector2i(chunk_x, chunk_y):
					current_chunk_data = chunk_data
					was_chunk_generated = true
					break
			
			if was_chunk_generated == false:
				current_chunk_data = save_new_chunk(chunk_x, chunk_y)
			
			#sets tiles in worlds tilemap
			for x in range(current_chunk_data["chunk_tiles"].size()):
				for y in range(current_chunk_data["chunk_tiles"][x].size()):
					tilemap.set_cell(Vector2i(chunk_x*chunk_size.x + x, chunk_y*chunk_size.y + y), 0, current_chunk_data["chunk_tiles"][x][y])
			
			#instantiates static entities
			for entity_data in current_chunk_data["generated_entities"]:
				var entity_instance = entity_data["scene"].instantiate()
				entity_instance.global_position = entity_data["world_pos"]
				tilemap.get_parent().find_child("StaticEntities").add_child(entity_instance)
				
				var instance_data = {
					"instance_ref": entity_instance,
					"chunk_vector": Vector2i(chunk_x, chunk_y),
					"entity_id": entity_data["id"]
				}
				instantiated_static_entities.append(instance_data)
			loaded_chunks.append(Vector2i(chunk_x, chunk_y))


func load_chunks_around_chunk(chunk_x, chunk_y):
	var chunks_loaded_this_iteration = []
	for x in range(chunk_x-1, chunk_x+2):  #3 chunks horizontal
		for y in range(chunk_y-1, chunk_y+2):  #3 chunks vertical
			chunks_loaded_this_iteration.append(Vector2i(x, y))
	
	for chunk in loaded_chunks.duplicate(): #unload (has to be duplicated cause iterating over an array and removing at the same time)
		if chunk not in chunks_loaded_this_iteration:
			unload_chunk(chunk.x, chunk.y) #<this has removing indexes
	
	for chunk in chunks_loaded_this_iteration: #load
		load_chunk(chunk.x, chunk.y)


func check_if_player_crossed_chunks(player_position):
	var player_position_tilemap = tilemap.local_to_map(player_position)
	var chunk_x = floor(player_position_tilemap.x*1.0 / chunk_size.x*1.0) #cant use normal division, wrong results
	var chunk_y = floor(player_position_tilemap.y*1.0 / chunk_size.y*1.0)
	var player_occupied_chunk = Vector2i(chunk_x, chunk_y) 
	
	if player_occupied_chunk != last_chunk_visited:
		last_chunk_visited = player_occupied_chunk
		load_chunks_around_chunk(chunk_x, chunk_y)
		player_current_biome = get_chunk_biome(player_position)


func create_2d_array(rows, cols, fill_val) -> Array:
	var array = []
	array.resize(rows)
	for row in range(array.size()):
		array[row] = []
		array[row].resize(cols)
		array[row].fill(fill_val)
	return array


func chunk_pos_to_array_index_vector(posx, posy):
	var chunk_array_size = saved_chunks.size()
	var index_x = (posx % chunk_array_size + chunk_array_size) % chunk_array_size
	var index_y = (posy % chunk_array_size + chunk_array_size) % chunk_array_size
	return Vector2i(index_x, index_y)


func get_chunk_biome(pos):
	var pos_in_tilemap = tilemap.local_to_map(pos)
	var chunk_x = floor(pos_in_tilemap.x*1.0 / chunk_size.x*1.0)
	var chunk_y = floor(pos_in_tilemap.y*1.0 / chunk_size.y*1.0)
	load_chunk(chunk_x, chunk_y)
	for chunk_data in saved_chunks:
			if chunk_data["chunk_pos"] == Vector2i(chunk_x, chunk_y):
				return chunk_data["biome"]


func generate_static_entities(world_offset_vector, chunk_tiles, chunk_biome):
	var generated_entities: Array
	for x in range(chunk_size.x):
		for y in range(chunk_size.y):
			for entity_data in static_entities_data:
				if entity_data["biome"] != chunk_biome:
					continue
				if rng.randi_range(1, entity_data["chance"]) == 1:
					if tilemap:
						var generation_pos = world_offset_vector + Vector2i(x, y)
						if chunk_tiles[x][y] != Vector2i(3, 2): #water
							chunk_tiles[x][y] == Vector2i(3, 2) #prevents new objects from being created at the same position
							var generated_entity_data = {
								"scene": entity_data["scene"],
								"world_pos": tilemap.map_to_local(generation_pos),
								"id": x*chunk_size.x + y
							}
							generated_entities.append(generated_entity_data)
	return generated_entities
