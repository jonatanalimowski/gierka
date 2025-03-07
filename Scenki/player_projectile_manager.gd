extends Node2D

@export var player_projectile_scene: PackedScene
@onready var player = get_tree().get_root().find_child("player", true, false)
func _ready() -> void:
	if not player:
		print("player proj manager nie widzi gracza")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_shoot(damage):
	var bullet = player_projectile_scene.instantiate()
	if not is_instance_valid(player):
			player = get_tree().get_root().find_child("player", true, false)
	else:
		var muzzle = player.find_child("Muzzle", true, false)
		var mouse_pos = get_global_mouse_position()
		var bullet_direction = (mouse_pos - muzzle.global_position).normalized()
		var angle = bullet_direction.angle()
	
		bullet.rotation = angle + PI/2
		bullet.direction = bullet_direction
		bullet.damage = damage
		bullet.global_position = muzzle.global_position
		get_tree().current_scene.add_child(bullet)
