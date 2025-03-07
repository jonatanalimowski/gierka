extends Control

@onready var ui_grid = $CraftingRecipeSelector/MarginContainer/GridContainer
var is_ui_visible = false
signal craft_item(recipe)


func _ready() -> void:
	add_to_group("crafting_ui")
	global.connect("toggle_crafting_ui", toggle_ui)
	global.connect("close_crafting_ui", close_ui)


func toggle_and_update_building_list(recipes):
	for child in ui_grid.get_children():
		child.queue_free()
	
	print(recipes)
	for recipe_data in recipes:
		var recipe = recipes[recipe_data]
		var hbox = HBoxContainer.new()
		var vbox = VBoxContainer.new()
		
		var recipe_texture = TextureRect.new()
		recipe_texture.texture = recipe.texture
		recipe_texture.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		ui_grid.add_child(recipe_texture)
		
		var recipe_name_label = Label.new()
		recipe_name_label.text = recipe.name
		recipe_name_label.custom_minimum_size.x = 200 
		
		var recipe_materials_label = Label.new()
		for material in recipe.crafting_materials:
			recipe_materials_label.text += str("Required " + material + ": " + str(recipe.crafting_materials[material]) + "\n")
		recipe_materials_label.text += "Level Requirement: " + str(recipe.lvl_req)

		
		var button = Button.new()
		button.text = "Craft"
		button.set_meta("recipe", recipe)
		button.pressed.connect(func():
			on_recipe_chosen(recipe)
		)
		
		vbox.add_child(recipe_name_label)
		vbox.add_child(button)
		hbox.add_child(vbox)
		hbox.add_child(recipe_materials_label)
		ui_grid.add_child(hbox)


func toggle_ui(recipes):
	if recipes:
		toggle_and_update_building_list(recipes)
	is_ui_visible = !is_ui_visible
	visible = is_ui_visible


func on_recipe_chosen(crafting_recipe):
	global.emit_signal("craft_item", crafting_recipe)


func close_ui():
	visible = false
	is_ui_visible = false
