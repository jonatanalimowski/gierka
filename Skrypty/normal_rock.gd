extends StaticEntity
var drop2 = {
	"item": preload("res://Resources/Items/rock.tres"),
	"max_amount": 6,
	"odds": 1
}

func _ready() -> void:
	health = 500
	drops.append(drop2)
	add_to_group("entity")
