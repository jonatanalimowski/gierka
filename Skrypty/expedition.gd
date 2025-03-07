extends Node2D #TEMP CODE


func _ready() -> void:
	global.connect("start_world_generation", set_tilemap)


func set_tilemap():
	var generator = get_tree().get_root().find_child("TEMP", true, false)
	print("whoaa")
	await generator.generate_map(69, $TileMapLayer)
