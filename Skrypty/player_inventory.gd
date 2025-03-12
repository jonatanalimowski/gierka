extends ItemContainer


signal updated
signal item_equipped(item)
signal item_unequipped(item)


var slot_types = ["head_armor", "chest_armor", "leg_armor", "boots", "amulet"]
var equipment: Dictionary = {
	"head_armor": null,
	"chest_armor": null,
	"leg_armor": null,
	"boots": null,
	"amulet": null
}

var sword_temp = load("res://Resources/Items/sword_pink.tres")

func _ready() -> void: #inicjuje inv_array wypelniajac nullami
	inv_array.resize(inv_size)
	inv_array.fill(null)
	inv_array[0] = sword_temp


func equip_item(inv_index, target_slot: String):
	var item = inv_array[inv_index]
	if not slot_types.has(item.slot):
		return
	if item and item.slot == target_slot and item.level_req <= global.player_level and equipment[target_slot] == null:
		equipment[target_slot] = item
		inv_array[inv_index] = null
		global.emit_signal("inventory_updated", self)
		emit_signal("item_equipped", item)


func unequip_item(slot: String):
	if equipment[slot] != null:
		if add_item(equipment[slot]):  #<-zwraca true jesli jest miejsce
			emit_signal("item_unequipped", equipment[slot])
			equipment[slot] = null
			global.emit_signal("inventory_updated", self)


func swap_inv_eq(inv_index, slot):
	var item = inv_array[inv_index]
	if item:
		if item.level_req <= global.player_level and item.equipment_item == true:
			var temp = equipment[slot]
			equipment[slot] = inv_array[inv_index]
			inv_array[inv_index] = temp
			global.emit_signal("inventory_updated", self)
			emit_signal("item_equipped", equipment[slot])
			emit_signal("item_unequipped", inv_array[inv_index])


func drop_item(inv_index, stack_size):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var original_item = inv_array[inv_index]
		if not original_item:
			return
		
		var dropped_item_data = original_item.duplicate(true)  #item_data to upuszczany przedmiot, inv_array opisuje przemdiot w eq
		if stack_size != null:
			dropped_item_data.stack_size = stack_size #jesli podane bylo stack_size do funkcji to upuszczonych przedmiotow tyle bedzie
			original_item.stack_size -= stack_size
		
		var dropped_item = preload("res://Scenki/dropped_item.tscn").instantiate()
		
		var drop_position = player.global_position + Vector2(randi_range(-100,100), randi_range(-100,100)) #szukanie pozycji gdzie mozna upuscic itemek
		while not global.is_area_free(drop_position):
			drop_position = player.global_position + Vector2(randi_range(-100,100), randi_range(-100,100))
		
		dropped_item.dropped_by_entity(dropped_item_data, drop_position, null)
	
		get_tree().current_scene.add_child(dropped_item)
		if stack_size == null or original_item.stack_size == 0: #jesli do funkcji podane ile upuscic to z inventory tyle znika, jesli nie, to znika calosc
			inv_array[inv_index] = null
			
		global.emit_signal("inventory_updated", self)


func drop_inventory():
	for i in range(inv_size):
		drop_item(i, null)
