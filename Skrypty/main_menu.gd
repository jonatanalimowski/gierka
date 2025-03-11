extends Control
var map_data
var seed

func _ready() -> void:
	seed = randi()%10000
	$VBoxContainer3/TextEdit.text_changed.connect(seed_entered)
	$VBoxContainer3/TextEdit.text = str(seed)
	$VBoxContainer/Quit.pressed.connect(quit_game)
	$VBoxContainer/Generate.pressed.connect(start_generation)
	$VBoxContainer2/GenerateNew.pressed.connect(start_generation)
	$VBoxContainer2/GenerateNew.visible = false
	$VBoxContainer2/Done.pressed.connect(generation_finished)
	$VBoxContainer2/Done.visible = false
	global.map_generated.connect(map_generated)


func seed_entered(new_seed):
	if new_seed.is_valid_int():
		seed = int(new_seed)
	else:
		$VBoxContainer3/TextEdit.text = str(seed)


func _process(delta: float) -> void:
	pass


func quit_game():
	get_tree().quit()


func start_generation():
	global.emit_signal("start_world_generation", seed)


func generation_finished():
	visible = false
	global.emit_signal("world_generation_finished", map_data)


func map_generated(tilemap):
	map_data = tilemap
	$VBoxContainer.visible = false
	$ColorRect.visible = false
	$VBoxContainer2/Done.visible = true
	$VBoxContainer2/GenerateNew.visible = true
