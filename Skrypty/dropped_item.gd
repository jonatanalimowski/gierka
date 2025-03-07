extends Node2D
class_name DroppedItem
var item: Item
var texture: Texture2D


func _ready() -> void:
	add_to_group("cleared_on_scene_change")
	add_to_group("dropped_item")
	if texture:
		$Sprite2D.texture = texture


func set_shape():
	if not $CollisionShape2D:
		var collision = CollisionShape2D.new()
		collision.shape = CircleShape2D
		collision.shape.radius = 17
		add_child(collision)
		$CollisionShape2D.disabled = false


func dropped_by_entity(item_dropped, dest_pos, eq_or_misc):
	if item_dropped != null:
		item = item_dropped
	else:
		if eq_or_misc == "misc":
			item = item_generator.generate_random_misc_item(null)
		if eq_or_misc == "eq":
			item = item_generator.generate_random_eq_item(null)

	texture = item.texture
	$Sprite2D.texture = texture
	global_position = dest_pos
