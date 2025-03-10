extends Control
var is_ui: bool = true
var item_container = ItemContainer.new()
var currently_chosen_item: Item = null
var chosen_slot_index = 0
@onready var toolbar_slots = $PanelContainer/MarginContainer/HBoxContainer


func _input(event: InputEvent): #choosing toolbar index
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var index = event.keycode - KEY_1
			choose_toolbar_slot(index)


func choose_toolbar_slot(index):
	if index == chosen_slot_index:
		toolbar_slots.get_child(index).set_chosen(true)
	else:
		toolbar_slots.get_child(chosen_slot_index).set_chosen(false)
		toolbar_slots.get_child(index).set_chosen(true)
		currently_chosen_item = item_container.inv_array[index] #!
		global.toolbar_chosen_item_changed.emit(currently_chosen_item)
		chosen_slot_index = index


func _ready() -> void:
	global.inventory_updated.connect(fill_and_update_ui)
	item_container.inv_size = 9
	item_container.container_name = "toolbar"
	item_container._ready() #doesnt work without manually calling _ready() for some reason??
	fill_and_update_ui(item_container)


func fill_and_update_ui(signalled_container):
	if signalled_container.container_name == "toolbar":
		if is_ui:
			for child in toolbar_slots.get_children():
				child.queue_free()

			#fill inventory
			for i in range(item_container.inv_size):
				var slot_instance = preload("res://Scenki/inventory_slot.tscn").instantiate()
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
				if i == chosen_slot_index:
					slot_instance.set_chosen(true)
					currently_chosen_item = item_container.inv_array[i]
					global.toolbar_chosen_item_changed.emit(currently_chosen_item)
				toolbar_slots.add_child(slot_instance)


func toggle_ui():
	is_ui = !is_ui
	visible = is_ui


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
