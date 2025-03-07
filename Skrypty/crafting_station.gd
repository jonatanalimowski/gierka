extends Node2D

var collisions_disabled = false
var is_active = true
@onready var building_data = load("res://Resources/Buildings/crafting_station.tres")

func toggle_collisions():
	collisions_disabled = !collisions_disabled
	$StaticBody2D/CollisionShape2D.disabled = collisions_disabled


func _ready() -> void:
	print($StaticBody2D/CollisionShape2D.disabled)
	$Area2D.add_to_group("building_interaction")
	add_to_group("building")
	global.connect("craft_item", craft_item)


func open_ui():
	if is_active:
		global.emit_signal("toggle_crafting_ui", building_data.recipes)


func craft_item(recipe):
	if check_if_craftable(recipe) and is_active:
		if player_inventory.add_item(recipe.crafting_product):
			for material in recipe.crafting_materials:
				player_inventory.remove_amount_from_inv(material, recipe.crafting_materials[material])
		else:
			print("brak miejsca w inv")

func check_if_craftable(recipe):
	var craftable = true
	for crafting_material in recipe.crafting_materials:
		if player_inventory.count_item_in_inventory(crafting_material) < recipe.crafting_materials[crafting_material]:
			print("not enough: ", crafting_material)
			craftable = false
	
	if global.player_level < recipe.lvl_req:
		print("need ", recipe.lvl_req - global.player_level, " level(s)")
		craftable = false
	
	return craftable
