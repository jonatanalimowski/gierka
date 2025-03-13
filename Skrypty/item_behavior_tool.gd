extends ItemBehavior
class_name ItemBehaviorTool

@export var tool_type = ""
@export var tool_strength: int
@export var weapon_damage: int
@export var tool_damage: int
var shapecast = ShapeCast2D.new()
var animation = AnimatedSprite2D.new()
var can_use: bool = true


func on_use(user_node, mouse_pos, damage = 0):
	can_use = true
	if can_use:
		var mouse_dir = (mouse_pos - user_node.global_position).normalized()
		
		#animation
		if not animation.is_inside_tree():
			user_node.add_child(animation)
		
		animation.sprite_frames = load("res://Scenki/tool_animation.tres")
		var angle = mouse_dir.angle()
		animation.rotation = angle
		animation.global_position = user_node.global_position + mouse_dir * 35
		
		#shapecast
		if not shapecast.is_inside_tree():
			user_node.add_child(shapecast)
		
		if shapecast.shape == null:
			shapecast.shape = CircleShape2D.new()
			shapecast.shape.radius = 25
		
		shapecast.global_position = user_node.global_position
		shapecast.target_position = mouse_dir * 75
		
		shapecast.force_shapecast_update()
		shapecast.set_collision_mask_value(5, true) #sets its to look for enemy type collisions
		animation.animation_finished.connect(func(): can_use = true)
		can_use = false
		animation.play("use_animation")
		if shapecast.is_colliding():
			var body = shapecast.get_collider(0)
			if body.is_in_group("tree_entity"):
				body.take_damage(tool_damage, tool_type)
			elif body.is_in_group("entity"):
				body.take_damage(weapon_damage + user_node.damage)
