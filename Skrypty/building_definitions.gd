extends Resource
class_name building_def

@export var building_scene: PackedScene = load("res://crafting_station.tscn")
@export var name: String = "Unknown building"
@export var description: String = "Default building description"
@export var texture: Texture2D
@export var level_requirement: int
@export var has_recipes: bool
@export var recipes: Dictionary
@export var has_inventory: bool
@export var inventory: Array
@export var materials_for_construction: Dictionary = {
	"Stick": 1,
	"Rope": 1
}
