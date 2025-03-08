extends EntityBehavior
class_name SlimeAI

@export var jump_force: float = 120.0
@export var jump_interval: float = 2.0
var time_since_last_jump: float = 0


func update(entity: Entity, delta: float):
	time_since_last_jump += delta
	if time_since_last_jump >= jump_interval:
		time_since_last_jump = 0
		var player = find_player(entity)
		if player:
			var direction = Vector2.ZERO
			if entity.global_position.distance_to(player.global_position) <= 500.0:
				direction = (player.global_position - entity.global_position).normalized()
			else:
				direction = (Vector2(randf_range(-1, 1), randf_range(-1, 1))).normalized()
			jump(entity, direction)
			
	entity.move_and_slide()


func jump(entity: Entity, direction):
	entity.velocity = direction * jump_force
	entity.get_tree().create_timer(0.5).timeout.connect(func(): #chatgpt wrote this part, didnt know you could declare functions like that 
		if entity:
			entity.velocity = Vector2.ZERO
	)


func find_player(entity):
	var player = entity.get_tree().get_first_node_in_group("player")
	return player
