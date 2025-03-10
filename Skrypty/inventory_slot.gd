extends Control

var item_data: Item = null
var item_container = null
var slot_texture_path = "res://Teksturki/inventory_slot.png"
@export var inv_index: int


var is_equipment: bool = false
var is_equipped: bool = false
var is_slot_equipment: bool = false
var eq_slot: String
var stack_size: int


func set_chosen(is_chosen):
	if is_chosen:
		$Slot.texture = load("res://Teksturki/chosen_inventory_slot.png")
		slot_texture_path = "res://Teksturki/chosen_inventory_slot.png"
	else:
		$Slot.texture = load("res://Teksturki/inventory_slot.png")


func _ready() -> void:
	$Slot.texture = load(slot_texture_path)
	connect("mouse_entered", mouse_entered)
	connect("mouse_exited", mouse_exited)


func change_to_item(texture):
	$Item/Label.visible = false
	if texture:
		$Item.texture = texture
	else:
		$Item.texture = null
	if item_data:
		if item_data.stackable:
			$Item/Label.text = str(item_data.stack_size)
			$Item/Label.visible = true


#domyslna funkcja, wywoluje sie jesli wykryje drag&drop na obiekcie
func _get_drag_data(position):

	if not item_data:
		return null

	var drag_data = {
		"item": item_data,
		"item_container": item_container,
		"inv_index": inv_index,
		"is_equipment": is_equipment,
		"is_equipped": is_equipped,
	}
	
	#ustawia obrazek przeciagania
	set_drag_preview($Item.duplicate())
	
	return drag_data


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("item")


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var from_index = data["inv_index"]
	var to_index = inv_index
	
	if data["item_container"] == item_container:
		if data["is_equipped"] and not is_equipped:
			player_inventory.unequip_item(data["item"].slot)
			
		elif not data["is_equipped"] and is_slot_equipment:
			player_inventory.equip_item(from_index, data["item"].slot)
		
		elif not data["is_equipped"] and not is_equipped:
			item_container.swap_items_inv(from_index, to_index)
		
	else: #przeniesienie z jednego kontenera do drugiego
		item_container.swap_items_between_containers(data["item_container"], item_container, data["inv_index"], inv_index)

func set_item_text():
	if item_data.equipment_item == true:
		$Tooltip/PanelContainer/MarginContainer/Label.text = "Level Requirement: " + str(item_data.level_req) + "\nItem name: " + str(item_data.name) + "\nItem description: " + str(item_data.description) + "\nHealth: " + str(item_data.health) + "\nDamage: " + str(item_data.damage) + "\nArmor: " + str(item_data.armor) + "\nSpeed: " + str(item_data.speed)
	else:
		$Tooltip/PanelContainer/MarginContainer/Label.text = "Item name: " + str(item_data.name) + "\nItem description: " + str(item_data.description) + "\nMax Stack: " + str(item_data.max_stack)


func show_tooltip(position: Vector2) -> void:
	$Tooltip.global_position = position + Vector2(0, -100)
	$Tooltip.visible = true


func hide_tooltip() -> void:
	$Tooltip.visible = false


func mouse_entered():
	if item_data:
		set_item_text()
		show_tooltip(get_global_mouse_position() + Vector2(10, 10))


func mouse_exited():
	$Tooltip.hide()
