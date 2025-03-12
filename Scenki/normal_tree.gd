extends StaticEntity
var drop2 = {
	"item": preload("res://Resources/Items/stick.tres"),
	"max_amount": 6,
	"odds": 1
}

func _ready() -> void:
	add_to_group("tree_entity")
	tool_to_damage = "Axe"
	health = 300
	drops.append(drop2)
	add_to_group("entity")
