extends StaticBody2D
class_name StaticEntity

#entity stats
@export var tool_to_damage: String = "no_tool"
@export var health: int = 100
@export var max_health: int
signal entity_damaged

#loot_table
var drops: Array

func _ready() -> void:
	max_health = health

func set_collisions():
	var collision_masks = [1, 3, 4]
	set_collision_layer_value(1, false)
	set_collision_layer_value(5, true)
	for mask in collision_masks:
		set_collision_mask_value(mask, true)
	add_to_group("enemy")
	add_to_group("entity")


func take_damage(damage, tool_type):
	if tool_type != tool_to_damage:
		damage = 10
	global.change_sprite_color(self, true)
	health -= damage
	entity_damaged.emit()
	if health <= 0:
		die()


func die():
	roll_for_drops()
	queue_free()


func roll_for_drops():
	var pos = global_position
	if drops:
		for i in range(drops.size()):
			var drop_data = drops[i]
			if drop_data:
				var roll = randi_range(1, drop_data["odds"])
				if roll == 1:
					var amount = randi_range(1, drop_data["max_amount"])
					drop_item(drop_data["item"], pos, amount)


func drop_item(item, pos, amount):
	var new_drop = preload("res://Scenki/dropped_item.tscn").instantiate()
	new_drop.global_position = pos
	item.stack_size = amount
	new_drop.dropped_by_entity(item, pos, null)
	var current_scene = get_tree().get_root().find_child("CurrentScene", true, false)
	current_scene.add_child(new_drop)
