extends Node2D
class_name Chest

var collisions_disabled = false
var is_active = true
var ui_open = false
@onready var building_data = load("res://Resources/Buildings/chest.tres")
@onready var item_container = $Item_Container
@onready var ui_grid = $CanvasLayer/Chest_UI/PanelContainer/MarginContainer/GridContainer


func toggle_collisions():
	collisions_disabled = !collisions_disabled
	$StaticBody2D/CollisionShape2D.disabled = collisions_disabled


func _ready() -> void:
	item_container.inv_size = 36
	$Area2D.add_to_group("building_interaction")
	add_to_group("building")
	add_to_group("cleared_on_scene_change")
	item_container.inv_array[6] = load("res://Resources/Items/abyssal_chestplate.tres")


func open_ui():
	ui_open = !ui_open
	$CanvasLayer/Chest_UI.visible = ui_open
	fill_and_update_inventory_ui()
	pass


func add_item(item: Item):
	if item_container:
		item_container.add_item(item)


func remove_item(inv_index, amount = null):
	if item_container:
		item_container.remove_item(inv_index, amount)


func look_for_item(item = null, item_name = null):
	if item_container:
		item_container.look_for_item(item, item_name)


func swap_items_inv(from_index, to_index):
	if item_container:
		item_container.swap_items_inv(from_index, to_index)


func count_item_in_inventory(item_name):
	if item_container:
		item_container.count_item_in_inventory(item_name)


func remove_amount_from_inv(item_name, amount):
	if item_container:
		item_container.remove_amount_from_inv(item_name, amount)


func fill_and_update_inventory_ui():
	if ui_open:
		var slot_scene = preload("res://Scenki/inventory_slot.tscn")
		ui_grid.columns = 6
		for child in ui_grid.get_children():
			child.queue_free()

		#fill inventory
		for i in range(item_container.inv_size):
			var slot_instance = slot_scene.instantiate()
			var item = item_container.inv_array[i]
			
			if item:
				slot_instance.item_data = item
				slot_instance.change_to_item(item.texture)
				if player_inventory.slot_types.has(item.slot):
					slot_instance.is_equipment = true
			else:
				slot_instance.change_to_item(null)
				
			slot_instance.inv_index = i
			slot_instance.is_slot_equipment = false
			ui_grid.add_child(slot_instance)
