extends Node
var seed = 0
var chunk_size = Vector2i(32, 32)
var saved_chunks = []
var loaded_chunks = []
var world_size: Vector2i
var tilemap: TileMapLayer
var last_chunk_visited = Vector2i(-100,-100)
var generator = WorldGenerator.new()
var player_current_biome: String
var biome_dict = { #currently unused
	Vector2i(3, 1): "Forest",
	Vector2i(3, 3): "Dunes",
	Vector2i(2, 2): "Tundra"
}

func set_chunk_loader_seed(seed):
	generator.initialise_noise_generator(seed)


func save_new_chunk(chunk_x, chunk_y): 
	if tilemap:
		
		generator.generate_map_array_from_seed(chunk_size, Vector2i(chunk_size.x * chunk_x, chunk_size.y * chunk_y))
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
		
		var chunk_data = {
			"chunk_pos": Vector2i(chunk_x, chunk_y),
			"chunk_tiles": chunk_tiles_array,
			"biome": current_biome
		}
		saved_chunks.append(chunk_data)
		return chunk_data


func unload_chunk(chunk_x, chunk_y):
	if Vector2i(chunk_x, chunk_y) in loaded_chunks:
		if tilemap:
			var current_chunk_data = []
			for chunk_data in saved_chunks:
				if chunk_data["chunk_pos"] == Vector2i(chunk_x, chunk_y):
					current_chunk_data = chunk_data["chunk_tiles"]
			
			if current_chunk_data:
				for x in range(current_chunk_data.size()):
					for y in range(current_chunk_data[x].size()):
						tilemap.set_cell(Vector2i(chunk_x*chunk_size.x + x, chunk_y*chunk_size.y + y), 0, Vector2i(-1, -1))
			
			loaded_chunks.erase(Vector2i(chunk_x, chunk_y))


func load_chunk(chunk_x, chunk_y):
	if Vector2i(chunk_x, chunk_y) not in loaded_chunks:
		var current_chunk_data = []
		var was_chunk_generated = false
		if tilemap:
			#if chunk was generated uses it to load tilemap, if not generates new chunk
			for chunk_data in saved_chunks:
				if chunk_data["chunk_pos"] == Vector2i(chunk_x, chunk_y):
					current_chunk_data = chunk_data["chunk_tiles"]
					was_chunk_generated = true
					break
			
			if was_chunk_generated == false:
				current_chunk_data = save_new_chunk(chunk_x, chunk_y)["chunk_tiles"]
			
			for x in range(current_chunk_data.size()):
				for y in range(current_chunk_data[x].size()):
					tilemap.set_cell(Vector2i(chunk_x*chunk_size.x + x, chunk_y*chunk_size.y + y), 0, current_chunk_data[x][y])
			
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
