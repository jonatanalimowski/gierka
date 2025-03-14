extends StaticEntity
var can_harvest = true
var drop1 = {
	"item": preload("res://Resources/Items/stick.tres"),
	"max_amount": 2,
	"odds": 1
}


func toggle_popup():
	print("hejka")
	if can_harvest:
		$Popup.visible = !$Popup.visible
	else:
		$Popup.visible = false


func _ready() -> void:
	tool_to_damage = "Axe"
	$Popup.visible = false
	health = 3
	drops.append(drop1)
	add_to_group("entity")
	$InteractArea.add_to_group("interactable")


func interact():
	if can_harvest:
		#player_inventory.add_item(drop1["item"])
		roll_for_drops()
		can_harvest = false
		toggle_popup()
