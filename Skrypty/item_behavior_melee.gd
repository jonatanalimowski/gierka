extends ItemBehavior
class_name ItemBehaviorMelee

var shapecast = ShapeCast2D.new()
var animation = AnimatedSprite2D.new()

func on_use(user_node, mouse_pos, damage = 0):
	var mouse_dir = (mouse_pos - user_node.global_position).normalized()
	
	#animation
	if not animation.is_inside_tree():
		user_node.add_child(animation)
	
	animation.sprite_frames = load("res://Scenki/melee_animation.tres")
	#animation.animation = &"new_animation"
	
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
	animation.play("new_animation")
	if shapecast.is_colliding():
		var body = shapecast.get_collider(0)
		if body.is_in_group("entity"):
			body.take_damage(damage)
	
	else:
		print("nic nie trafiono")
