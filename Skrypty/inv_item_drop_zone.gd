extends Control

func _ready():
	pass
	#self.mouse_filter = Control.MOUSE_FILTER_PASS

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("item")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not data["is_equipped"]:
		if data["item"].stack_size > 1:
			var drop_query = get_tree().get_root().find_child("DropQuery", true, false)
			drop_query.show_query(data)
		
		else:
			var inv_index = data["inv_index"]
			player_inventory.drop_item(inv_index, null)
