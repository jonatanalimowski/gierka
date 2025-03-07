extends Node2D

@onready var current_scene_container = $CurrentScene
@onready var ui = $CanvasLayer/UI

var player_spawn = Vector2(1000, 1000)


func _ready():
	ui.change_scene.connect(load_scene) 
	global.change_scene.connect(load_scene)
	global.world_generation_finished.connect(world_generation_finished)
	global.player_pos_set.connect(set_player_spawn)
	$CanvasLayer/UI.visible = false
	$CanvasLayer/MainMenu.visible = true


func load_scene(scene_path):
	if current_scene_container.get_child_count() > 0:  # Nie dodawaje tej samej sceny drugi raz
		var current_scene = current_scene_container.get_child(0)
		world_state.set_current_scene(current_scene)
		world_state.save_world_state()
		if current_scene.scene_file_path == scene_path:
			print("Scena już jest aktywna:", scene_path)
			return
	
	world_state.clear_instanced_objects()
	for child in current_scene_container.get_children():
		child.queue_free()
	
	var scene = load(scene_path).instantiate()
	current_scene_container.add_child(scene)
	world_state.set_current_scene(scene)
	world_state.load_world_state()


func world_generation_finished(tilemap):
	load_scene("res://Scenki/overworld.tscn")
	global.emit_signal("map_data_ready", tilemap)
	global.emit_signal("player_spawn_ready", player_spawn)
	
	$CanvasLayer/MainMenu.visible = false
	$CanvasLayer/UI.visible = true
	$TEMP.queue_free()


func set_player_spawn(pos):
	print(pos)
	player_spawn = pos
