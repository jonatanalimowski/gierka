extends StaticEntity
var drop2 = {
	"item": preload("res://Resources/Items/rock.tres"),
	"max_amount": 6,
	"odds": 1
}

func _ready() -> void:
	health = 200
	drops.append(drop2)
	tool_to_damage = "Pickaxe"
	add_to_group("entity")
	add_to_group("static_entity")
