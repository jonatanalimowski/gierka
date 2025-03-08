extends CharacterBody2D
class_name Entity

#entity stats
@export var health: int = 100
@export var damage: int = 0
@export var is_passive = true
@export var xp_drop = 1
@export var max_health: int
signal entity_damaged

#ai_type
var entity_behavior: EntityBehavior = null

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


func _physics_process(delta: float) -> void:
	if entity_behavior:
		entity_behavior.update(self, delta)


func take_damage(damage):
	global.change_sprite_color(self)
	health -= damage
	entity_damaged.emit()
	if health <= 0:
		die()


func die():
	global.add_xp(xp_drop)
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
