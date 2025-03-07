extends Node

signal updated
signal item_equipped(item)
signal item_unequipped(item)
var player = null


@export var drop: PackedScene
var inv_rows: int = 2
var inv_cols: int = 8
var inv_array: Array = []
var equipment: Dictionary = {
	"head_armor": null,
	"chest_armor": null,
	"leg_armor": null,
	"boots": null,
	"weapon": null
}


func _ready() -> void: #tworzy inv_array jako tablice dwuwymiarowa
	for i in range(inv_rows):
		inv_array.append([])
		for j in range(inv_cols):
			inv_array[i].append(null)


func add_item(item: Item) -> bool:
	if item.stackable:
		var inv_pos = look_for_item(item)
		
		if inv_pos == null: #jesli nie ma takiego itemku w inv to normalnie dodaje
			for i in range(inv_rows):
				for j in range(inv_cols):
					if inv_array[i][j] == null:
						inv_array[i][j] = item
						emit_signal("updated")
						return true
			return false  #<-false jesli brak miejsca w eq
			
		else: #jesli jest w inventory taki itemek to zwieksza ilosc stacku
			inv_array[inv_pos.x][inv_pos.y].stack_size += item.stack_size
			emit_signal("updated")
			return true
		
	else:
		for i in range(inv_rows):
			for j in range(inv_cols):
				if inv_array[i][j] == null:
					inv_array[i][j] = item
					emit_signal("updated")
					return true
		return false  #<-false jesli brak miejsca w eq


func remove_item(index_row: int, index_col: int, amount = null):
	if not amount:
		if inv_array[index_row][index_col] != null:
			inv_array[index_row][index_col] = null
			emit_signal("updated")
	else:
		if inv_array[index_row][index_col] != null:
			if inv_array[index_row][index_col].stack_size - amount <= 0:
				inv_array[index_row][index_col] = null
			else:
				inv_array[index_row][index_col].stack_size -= amount
		emit_signal("updated")

func equip_item(index_row: int, index_col: int, target_slot: String):
	var item = inv_array[index_row][index_col]
	if item and item.slot == target_slot and item.level_req <= global.player_level:
		equipment[target_slot] = item
		inv_array[index_row][index_col] = null
		emit_signal("updated")
		emit_signal("item_equipped", item)


func unequip_item(slot: String):
	if equipment[slot] != null:
		if add_item(equipment[slot]):  #<-zwraca true jesli jest miejsce
			emit_signal("item_unequipped", equipment[slot])
			equipment[slot] = null
			emit_signal("updated")


func swap_items_inv(fromy, fromx, toy, tox):
	var temp = inv_array[tox][toy]
	inv_array[tox][toy] = inv_array[fromx][fromy]
	inv_array[fromx][fromy] = temp
	emit_signal("updated")


func swap_inv_eq(fromy, fromx, slot):
	var item = inv_array[fromx][fromy]
	if item.level_req <= global.player_level and item.equipment_item == true:
		var temp = equipment[slot]
		equipment[slot] = inv_array[fromx][fromy]
		inv_array[fromx][fromy] = temp
		emit_signal("updated")
		emit_signal("item_equipped", equipment[slot])
		emit_signal("item_unequipped", inv_array[fromx][fromy])


func drop_item(fromy, fromx, stack_size):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var original_item = inv_array[fromx][fromy]
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
			inv_array[fromx][fromy] = null
			
		emit_signal("updated")


func look_for_item(item = null, item_name = null):
	if item != null:
		for i in range(inv_rows):
			for j in range(inv_cols):
				if inv_array[i][j] != null:
					if inv_array[i][j].name == item.name and (inv_array[i][j].stack_size + item.stack_size) <= inv_array[i][j].max_stack:
						return Vector2i(i, j)
	
	else:
		for i in range(inv_rows):
			for j in range(inv_cols):
				if inv_array[i][j] != null:
					if inv_array[i][j].name == item_name:
						return Vector2i(i, j)
	return null


func count_item_in_inventory(item_name):
	var amount = 0
	for i in range(inv_rows):
		for j in range(inv_cols):
			var item = inv_array[i][j]
			if item != null:
				if item.name == item_name:
					amount += item.stack_size
	return amount


func remove_amount_from_inv(item_name, amount):
	var inventory_pos = inventory.look_for_item(null, item_name)
	if inventory_pos: #musialby byc potezny edge case zeby ten if nie przeszedl, ale w razie czego to jeden krasz mniej
		inventory.remove_item(inventory_pos.x, inventory_pos.y, amount)
		print("Removed ", amount, item_name)
	emit_signal("updated")
