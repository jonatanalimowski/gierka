extends Node2D

var pickup_object = PickupEnity.new()

func _ready() -> void:
	pickup_object.pickup_item_texture = load("res://Teksturki/misc_item_textures/rock_item.png")
	pickup_object.pickup_item = load("res://Resources/Items/rock.tres")
	pickup_object.picked_up.connect(on_pickup)
	add_child(pickup_object)


func on_pickup():
	queue_free()


func interact():
	pickup_object.on_interaction()


func toggle_popup():
	pickup_object.toggle_popup()
