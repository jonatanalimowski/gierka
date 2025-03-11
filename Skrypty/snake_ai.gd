extends EntityBehavior
class_name SnakeAI
@export var walk_speed: float = 200.0
var walk_time = 2.0
var stand_time = 1.5
var animation: AnimatedSprite2D

func update(entity: Entity, delta: float):
	var player = find_player(entity)
	
	if player and entity.global_position.distance_to(player.global_position) <= 300.0:
		var direction = (player.global_position - entity.global_position).normalized()
		animation.play("walk")
		var angle = direction.angle()
		animation.rotation = angle
		entity.velocity = direction * walk_speed
	else:
		if not entity.has_meta("wandering") or not entity.get_meta("wandering"):
			wander(entity)
	
	if is_instance_valid(entity):
		entity.move_and_slide()


func wander(entity):
	entity.set_meta("wandering", true)  #sets flag when player is far away
	
	while not find_player(entity) or entity.global_position.distance_to(find_player(entity).global_position) > 300.0:
		var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		if is_instance_valid(entity):
			var angle = direction.angle()
			animation.rotation = angle
			animation.play("walk")
			entity.velocity = direction * walk_speed
			await entity.get_tree().create_timer(walk_time).timeout
		
		if is_instance_valid(entity):
			entity.velocity = Vector2.ZERO
			animation.stop()
			await entity.get_tree().create_timer(stand_time).timeout
			
		if not is_instance_valid(entity):
			return
	entity.set_meta("wandering", false)  #resets meta flag when player gets close


func find_player(entity):
	if is_instance_valid(entity):
		var player = entity.get_tree().get_first_node_in_group("player")
		return player
