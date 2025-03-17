extends Node2D

var collisions_disabled = false
var is_active = true
var ui_open = false
var is_popup = false
var loaded_inv_array = []

@onready var building_data = load("res://Resources/Buildings/chest.tres")
@onready var popup = $Popup
@onready var item_container = $Item_Container
@onready var ui_grid = $CanvasLayer/Chest_UI/PanelContainer/MarginContainer/GridContainer


func toggle_popup():
	if is_active:
		is_popup = !is_popup
		popup.visible = is_popup


func toggle_collisions():
	collisions_disabled = !collisions_disabled
	$StaticBody2D/CollisionShape2D.disabled = collisions_disabled


func _ready() -> void:
	popup.visible = false
	item_container.container_name = "chest_container"
	if loaded_inv_array:
		item_container.inv_array = loaded_inv_array
	item_container.inv_size = 36
	$Area2D.add_to_group("building_interaction")
	add_to_group("building")


func open_ui():
	global.emit_signal("open_chest_ui", item_container)


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


func swap_items_between_containers(cont1, cont2, cont1_index, cont2_index):
	if item_container:
		item_container.swap_items_between_containers(cont1, cont2, cont1_index, cont2_index)
