extends Control

@onready var ui_grid = $BuildingRecipeSelector/MarginContainer/GridContainer
@onready var build_mode = get_tree().get_root().find_child("build_mode", true, false)

func _ready() -> void:
	if not build_mode:
		print("building ui nie widzi build mode")
	update_building_list()


func update_building_list():
	for child in ui_grid.get_children():
		child.queue_free()
	
	for building_recipe in global.available_buildings:
		var hbox = HBoxContainer.new()
		var vbox = VBoxContainer.new()
		
		var recipe_texture = TextureRect.new()
		recipe_texture.texture = building_recipe.texture
		ui_grid.add_child(recipe_texture)
		
		var recipe_name_label = Label.new()
		recipe_name_label.text = building_recipe.name
		
		var recipe_materials_label = Label.new()
		for material in building_recipe.materials_for_construction:
			recipe_materials_label.text += str("Required " + material + ": " + str(building_recipe.materials_for_construction[material]) + "\n")
		recipe_materials_label.text += "Level Requirement: " + str(building_recipe.level_requirement)

		
		var button = Button.new()
		button.text = "Build"
		button.set_meta("building_recipe", building_recipe)
		button.pressed.connect(func():
			on_recipe_chosen(building_recipe)
		)
		
		vbox.add_child(recipe_name_label)
		vbox.add_child(button)
		hbox.add_child(vbox)
		hbox.add_child(recipe_materials_label)
		ui_grid.add_child(hbox)


func on_recipe_chosen(building_recipe):
	var can_build = true
	for item_name in building_recipe.materials_for_construction:
		if player_inventory.count_item_in_inventory(item_name) < building_recipe.materials_for_construction[item_name]:
			can_build = false
	
	if building_recipe.level_requirement > global.player_level:
		can_build = false
	
	if can_build:
		build(building_recipe)
		
	else:
		print("sory mordziaty")


func build(building_recipe):
	while not build_mode: #potential infinite loop (worth finding a better solution for those)
		build_mode = get_tree().get_root().find_child("build_mode", true, false)
	
	build_mode.start_building_mode(building_recipe)
