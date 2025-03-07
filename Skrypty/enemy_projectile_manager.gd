extends Node2D

@export var slime_projectile_scene: PackedScene
@onready var player = get_tree().get_root().find_child("player", true, false)

func _ready() -> void:
	if player:
		print("Gracz znaleziony przez projectile manager")
	else:
		print("projectile manager nie widzi gracza")


func _process(delta: float) -> void:
	pass


func spawn_projectile(spawn_position: Vector2, speed: float, damage: float) -> void:
	var bullet = slime_projectile_scene.instantiate()
	if is_instance_valid(player):
		var player_pos = player.global_position
		var bullet_direction = (player_pos - spawn_position).normalized() 
		var angle = bullet_direction.angle() 
	
		bullet.rotation = angle + PI/2
		bullet.direction = bullet_direction
		bullet.damage = damage
		bullet.speed = speed
		bullet.global_position = spawn_position
		get_tree().current_scene.add_child(bullet)
	else:
		player = get_tree().get_root().find_child("player", true, false)
	
