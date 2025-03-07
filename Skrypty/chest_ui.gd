extends Control

var is_chest_ui = false
@onready var chest_ui_grid = $PanelContainer/MarginContainer/GridContainer


func _ready() -> void:
	visible = false
	global.inventory_updated.connect(fill_and_update_chest_ui)
	global.open_chest_ui.connect(open_chest_ui)
	global.close_building_ui.connect(close_ui)


func fill_and_update_chest_ui(item_container):
	if item_container.container_name == "chest_container":
		if is_chest_ui:
			print("updating chest ui")
			var slot_scene = preload("res://Scenki/inventory_slot.tscn")
			chest_ui_grid.columns = 6
			for child in chest_ui_grid.get_children():
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
				slot_instance.item_container = item_container
				slot_instance.is_slot_equipment = false
				chest_ui_grid.add_child(slot_instance)


func open_chest_ui(item_container):
	is_chest_ui = !is_chest_ui
	visible = is_chest_ui
	fill_and_update_chest_ui(item_container)


func close_ui():
	visible = false
	is_chest_ui = false
