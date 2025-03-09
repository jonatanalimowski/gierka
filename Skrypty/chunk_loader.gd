extends Node
var seed = 0
var chunk_size = Vector2i(32, 32)
var saved_chunks = []
var loaded_chunks = []
var world_size: Vector2i
var tilemap: TileMapLayer
var last_chunk_visited = Vector2i(-100,-100)
var generator = WorldGenerator.new()


func initialise_chunk_data(world_dims): #when the world has been created
	if tilemap:
		world_size = world_dims
		saved_chunks = create_2d_array(world_size.x/chunk_size.x, world_size.y / chunk_size.y, null)
		
		for row in range(saved_chunks.size()):
			for col in range(saved_chunks[row].size()):
				saved_chunks[row][col] = create_2d_array(chunk_size.x, chunk_size.y, null)
			
		for row in range(world_size.x):
			for col in range(world_size.y): #every index should be int; if its not something went really wrong
				var chunk_x = row / chunk_size.x  #index in saved_chunks
				var chunk_y = col / chunk_size.y
				var tile_x = row % chunk_size.x  #tile index in chunk array
				var tile_y = col % chunk_size.y
				
				var tile_data = tilemap.get_cell_atlas_coords(Vector2i(row, col))
				if tile_data:
					saved_chunks[chunk_x][chunk_y][tile_x][tile_y] = tile_data


func unload_chunk(chunk_x, chunk_y):
	if Vector2i(chunk_x, chunk_y) in loaded_chunks:
		if tilemap:
			var chunk_index = chunk_pos_to_array_index_vector(chunk_x, chunk_y)
			for tile_x in range(chunk_size.x):
				for tile_y in range(chunk_size.y):
					var tile_pos = Vector2i(chunk_size.x * chunk_x + tile_x, chunk_size.y * chunk_y + tile_y)
					tilemap.set_cell(tile_pos, 0, Vector2i(-1, -1))
			loaded_chunks.erase(Vector2i(chunk_x, chunk_y))


func load_chunk(chunk_x, chunk_y):
	if Vector2i(chunk_x, chunk_y) not in loaded_chunks:
		if tilemap:
			var chunk_index = chunk_pos_to_array_index_vector(chunk_x, chunk_y)
			for tile_x in range(chunk_size.x):
				for tile_y in range(chunk_size.y):
					var tile_pos = Vector2i(chunk_size.x * chunk_x + tile_x, chunk_size.y * chunk_y + tile_y)
					tilemap.set_cell(tile_pos, 0, saved_chunks[chunk_index.x][chunk_index.y][tile_x][tile_y])
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
