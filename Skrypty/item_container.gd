extends Node
class_name ItemContainer

@export var container_name: String = ""
@export var inv_size: int = 16
var inv_array: Array = []

func _ready():
	inv_array.resize(inv_size)
	inv_array.fill(null)


func add_item(item: Item) -> bool:
	var inv_index = null
	if item.stackable:
		inv_index = look_for_item(item)
		
	if inv_index == null: #normalne dodawanie; jesli itemek nie jest stakowalny, albo nie ma miejsca w staku
		for i in range(inv_size):
				if inv_array[i] == null:
					inv_array[i] = item.duplicate()
					global.emit_signal("inventory_updated", self)
					return true
		return false  #<-false jesli brak miejsca w eq
	
	else: #jesli jest w inventory taki itemek i jest miejsce w staku to zwieksza ilosc stacku
		inv_array[inv_index].stack_size += item.stack_size
		global.emit_signal("inventory_updated", self)
		return true


func remove_item(inv_index, amount = null):
	if amount == null:
		if inv_array[inv_index] != null:
			inv_array[inv_index] = null
			global.emit_signal("inventory_updated", self)
	else:
		if inv_array[inv_index] != null:
			if inv_array[inv_index].stack_size - amount <= 0:
				inv_array[inv_index] = null
			else:
				inv_array[inv_index].stack_size -= amount
		global.emit_signal("inventory_updated", self)


func look_for_item(item = null, item_name = null):
	if item != null:
		for i in range(inv_size):
			if inv_array[i] != null:
				if inv_array[i].name == item.name and (inv_array[i].stack_size + item.stack_size) <= inv_array[i].max_stack:
					return i
	
	else:
		for i in range(inv_size):
			if inv_array[i] != null:
				if inv_array[i].name == item_name:
					return i
	return null


func swap_items_inv(from_index, to_index):
	print("swtapping:!")
	var item1 = inv_array[from_index]
	var item2 = inv_array[to_index]
	print(item1, item2)
	if from_index == to_index:
		return
	if item1 != null and item2 != null:
		if item1.name == item2.name and item1.stackable == true:
			var stack_space_left = item2.max_stack - item2.stack_size
			
			if item1.stack_size <= stack_space_left:
				item2.stack_size += item1.stack_size
				inv_array[from_index] = null
			else:
				item2.stack_size = item2.max_stack
				item1.stack_size -= stack_space_left
				
			global.emit_signal("inventory_updated", self)
		else:
			inv_array[to_index] = inv_array[from_index]
			inv_array[from_index] = item2
			global.emit_signal("inventory_updated", self)
	else:
		inv_array[to_index] = inv_array[from_index]
		inv_array[from_index] = item2
		global.emit_signal("inventory_updated", self)


func count_item_in_inventory(item_name):
	var amount = 0
	for i in range(inv_size):
		var item = inv_array[i]
		if item != null:
			if item.name == item_name:
				amount += item.stack_size
	return amount


func remove_amount_from_inv(item_name, amount):
	var inventory_pos = look_for_item(null, item_name)
	if inventory_pos != null: #musialby byc potezny edge case zeby ten if nie przeszedl, ale w razie czego to jeden krasz mniej
		remove_item(inventory_pos, amount)
	global.emit_signal("inventory_updated", self)


func swap_items_between_containers(cont1, cont2, cont1_index, cont2_index):
	if cont1.inv_array[cont1_index] != null and cont2.inv_array[cont2_index] != null:
		if cont1.inv_array[cont1_index].name == cont2.inv_array[cont2_index].name:
			cont2.add_item(cont1.inv_array[cont1_index])
			cont1.inv_array[cont1_index] = null
		else:
			var temp = cont1.inv_array[cont1_index]
			cont1.inv_array[cont1_index] = cont2.inv_array[cont2_index]
			cont2.inv_array[cont2_index] = temp
	else:
		var temp = cont1.inv_array[cont1_index]
		cont1.inv_array[cont1_index] = cont2.inv_array[cont2_index]
		cont2.inv_array[cont2_index] = temp
	
	global.emit_signal("inventory_updated", cont1)
	global.emit_signal("inventory_updated", cont2)
