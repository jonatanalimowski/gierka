extends Node
class_name WorldGenerator

@export var world_size: Vector2i
signal update_generation_progress(percent)
signal generation_finished
signal generation_started
var total_steps: float #PROGRESS_INFO
var steps_done: float #PROGRESS_INFO
var random
var tiles_for_generation = [Vector2i(3, 1), Vector2i(3, 2)]
var world_data = []


func generate_map_array_from_seed(seed):
	emit_signal("generation_started")
	steps_done = 0
	
	random = RandomNumberGenerator.new()
	random.seed = seed
	var automata_steps = 50
	var smoothing_steps = 15
	var both_steps = 5
	total_steps = automata_steps + both_steps*2 + smoothing_steps #PROGRESS_INFO
	
	#1: creates an array with dimenions extended in every way by one then fills with ones (walls)
	world_data.resize(world_size.x + 2)
	for x in range(world_size.x + 2):
		world_data[x] = []
		world_data[x].resize(world_size.y + 2)
		world_data[x].fill(1)
	
	#2: fills array with noise, ignoring borders
	for x in range(1, world_size.x+1):
		for y in range(1, world_size.y+1):
			world_data[x][y] = random.randi_range(0,1)
	
	
	#3: apply cellular automata
	for i in range(automata_steps):
		await apply_cellular_automata(1)

	#4: apply smoothing
	for i in range(smoothing_steps):
		await apply_smoothing(1)
	
	#5: apply both
	for i in range(both_steps):
		await apply_cellular_automata(1)
		await apply_smoothing(1)
	
	emit_signal("generation_finished")


func create_map_from_array(tilemap, offset = Vector2(0, 0)):
	if world_data:
		for x in range(world_size.x):
			for y in range(world_size.y):
				tilemap.set_cell(Vector2i(x+offset.x, y+offset.y), 0, tiles_for_generation[world_data[x+1][y+1]])
	else:
		print("generate_map_array not initialised")


func apply_cellular_automata(automata_iterations):
	var new_world_data = world_data.duplicate(true)
	for iteration in range(automata_iterations):
		for x in range(1, world_size.x+1):
			for y in range(1, world_size.y+1):
				var neighbors = count_neighbors_in_array(x, y)
				
				if neighbors["ones"] >= 6:
					new_world_data[x][y] = 1
				
				elif neighbors["ones"] <= 2:
					new_world_data[x][y] = 0
				
				else:
					new_world_data[x][y] = random.randi_range(0,1)
		
		steps_done += 1 #PROGRESS_INFO
		await get_tree().process_frame #PROGRESS_INFO
		emit_signal("update_generation_progress", snapped((steps_done/total_steps), 0.01)*100) #returns percentage done 
		
		world_data = new_world_data


func apply_smoothing(smoothing_iterations):
	var new_world_data = world_data.duplicate(true)
	for iteration in range(smoothing_iterations):
		for x in range(1, world_size.x+1):
			for y in range(1, world_size.y+1):
				var neighbors = count_neighbors_in_array(x, y)
				
				if neighbors["ones"] < 5:
					new_world_data[x][y] = 0
				
				elif neighbors["zeroes"] < 5:
					new_world_data[x][y] = 1
		
		steps_done += 1 #PROGRESS_INFO
		await get_tree().process_frame #PROGRESS_INFO
		emit_signal("update_generation_progress", snapped((steps_done/total_steps), 0.01)*100) #returns percentage done
			
		world_data = new_world_data


func count_neighbors_in_array(x_index, y_index):
	var zeroes = 0
	var ones = 0
	
	#neighbors
	var neighbors = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),                  Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)
	]
	
	for offset in neighbors:
		var nx = x_index + offset.x
		var ny = y_index + offset.y
		
		if world_data[nx][ny] == 0:
			zeroes += 1
		else:
			ones += 1
	
	#returns dict
	return { "zeroes": zeroes, "ones": ones }
