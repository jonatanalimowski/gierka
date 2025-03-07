extends Node2D
@onready var generator = WorldGenerator.new()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		$Camera2D.position = get_global_mouse_position()
	
	if event.is_action_pressed("build_mode_toggle"):
		generator.apply_cellular_automata()
		generator.create_map_from_array($TileMapLayer)
		
	if event.is_action_pressed("inventory"):
		generator.apply_smoothing()
		generator.create_map_from_array($TileMapLayer)
		
func _ready() -> void:
	generator.world_size = Vector2i(250, 250)
	generator.generate_map_array_from_seed(69420)
	generator.create_map_from_array($TileMapLayer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
