extends Area2D
@export var destination = "res://Scenki/expedition.tscn"
@export var is_base = false

func _ready() -> void:
	add_to_group("teleport")
