extends Node
class_name WorldGenerator

@export var preview_size: Vector2i
signal update_generation_progress(percent)
signal generation_finished
signal generation_started
var total_steps: float #PROGRESS_INFO LEFTOVER
var steps_done: float #PROGRESS_INFO LEFTOVER
var noise
var tiles_for_generation = [Vector2i(3, 1), Vector2i(3, 2)] #0 grass, #1 land
var world_data: Array = []


func initialise_noise_generator(seed):
	noise = FastNoiseLite.new()
	noise.seed = seed


func generate_map_array_from_seed(size: Vector2i = preview_size, offset = Vector2i(0, 0)):
	emit_signal("generation_started")
	total_steps = preview_size.x
	steps_done = 0
	
	#initialises map array
	world_data.resize(size.x)
	for x in range(size.x):
		world_data[x] = []
		world_data[x].resize(size.y)
	
	#fills with godots perlin noise
	for x in range(size.x):
		for y in range(size.y):
			if noise.get_noise_2d(x+offset.x, y+offset.y) < -0.1:
				world_data[x][y] = 1
			else:
				world_data[x][y] = 0
		#await get_tree().process_frame #PROGRESS_INFO
		#emit_signal("update_generation_progress", snapped((steps_done/total_steps), 0.01)*100)
	
	emit_signal("generation_finished")


func change_numbers_to_tile_vectors(array2d):
	var vector_array = chunk_loader.create_2d_array(array2d.size(), array2d[0].size(), null)
	for x in range(array2d.size()):
		for y in range(array2d[x].size()):
			vector_array[x][y] = tiles_for_generation[array2d[x][y]]
	return vector_array


func create_map_from_array(tilemap, offset = Vector2(0, 0), size: Vector2i = preview_size):
	if world_data:
		for x in range(size.x):
			for y in range(size.y):
				tilemap.set_cell(Vector2i(x+offset.x, y+offset.y), 0, tiles_for_generation[world_data[x][y]])
	else:
		print("generate_map_array not initialised")
