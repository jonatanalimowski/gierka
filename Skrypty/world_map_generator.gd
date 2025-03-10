extends Node2D
@onready var generator = $Node
var offset = Vector2(0, 0)
var player_pos: Vector2
var world_dims = Vector2i(256, 256)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		$Camera2D.position = get_global_mouse_position()
	
	if event.is_action_pressed("wheel_up"):
		$Camera2D.zoom *= 1.15
	
	if event.is_action_pressed("wheel_down"):
		$Camera2D.zoom /= 1.15
		
	#if event.is_action_pressed("up"):
	
	#if event.is_action_pressed("down"):
	
	if event.is_action_pressed("right_mouse"):
		player_pos = get_global_mouse_position()
		global.emit_signal("player_pos_set", player_pos)


func _ready() -> void:
	$CanvasLayer/Label.visible = false
	global.start_world_generation.connect(generate_map)
	generator.update_generation_progress.connect(update_progress)
	generator.generation_finished.connect(generation_finished)
	generator.generation_started.connect(generation_started)
	generator.preview_size = world_dims


func generation_finished():
	$CanvasLayer/Label.visible = false


func generation_started():
	$CanvasLayer/Label.visible = true
	$CanvasLayer/Label.text = "0% / 100%"


func update_progress(percentage):
	$CanvasLayer/Label.text = str(percentage) + "% / 100%"


func generate_map(seed=69, tilemap=$TileMapLayer):
	generator.initialise_noise_generator(seed)
	chunk_loader.set_chunk_loader_seed(seed)
	generator.generate_map_array_from_seed()
	generator.create_map_from_array(tilemap)
	chunk_loader.tilemap = $TileMapLayer
	#chunk_loader.initialise_chunk_data(world_dims)
	global.emit_signal("map_generated", tilemap.duplicate())
