extends Area2D
class_name PickupEnity
signal picked_up

#item on pickup
@export var pickup_item: Item
@export var pickup_item_texture: Texture2D

func _ready() -> void:
	set_texture()
	set_collisions()
	set_interactions()


func set_texture():
	var sprite = Sprite2D.new()
	sprite.texture = pickup_item_texture
	add_child(sprite)


func set_interactions():
	var popup = Sprite2D.new()
	popup.texture = load("res://Teksturki/UI_textures/press_e_popup.png")
	popup.visible = false
	popup.position += Vector2(0, -30)
	popup.name = "Popup"
	add_child(popup)


func set_collisions():
	var collision = CollisionShape2D.new()
	collision.shape = CircleShape2D.new()
	collision.shape.radius = 15
	add_child(collision)
	add_to_group("interactable")


func toggle_popup():
	$Popup.visible = !$Popup.visible


func on_interaction():
	on_pickup()


func on_pickup():
	player_inventory.add_item(pickup_item)
	emit_signal("picked_up")
