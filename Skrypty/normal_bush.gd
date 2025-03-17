extends StaticEntity
var can_harvest = true
var drop1 = {
	"item": preload("res://Resources/Items/stick.tres"),
	"max_amount": 2,
	"odds": 1
}


func toggle_popup():
	if can_harvest:
		$Popup.visible = !$Popup.visible
	else:
		$Popup.visible = false


func _ready() -> void:
	tool_to_damage = "no_tool"
	$Popup.visible = false
	health = 3
	drops.append(drop1)
	add_to_group("entity")
	add_to_group("static_entity")
	$InteractArea.add_to_group("interactable")


func interact():
	if can_harvest:
		var drop_item = drop1["item"].duplicate()
		drop_item.stack_size = randi_range(1, drop1["max_amount"])
		player_inventory.add_item(drop_item)
		can_harvest = false
		toggle_popup()
