extends Resource
class_name Item

@export var name: String = "Unnamed Item"
@export var slot: String = "unequippable"
@export var description: String = ""
@export var level_req: int = 1
@export var damage: int = 0
@export var speed: int = 0
@export var health: int = 0
@export var armor: int = 0
@export var texture: Texture
@export var stackable: bool = false
@export var stack_size: int = 1
@export var max_stack: int = 50
@export var equipment_item: bool = true
@export var usable_item: bool = false
#var item_behavior: ItemBehavior = null
