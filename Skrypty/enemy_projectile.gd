extends Area2D

@export var speed: float = 400.0
@export var damage: float = 25.0
@export var lifetime: float = 2.0
var direction := Vector2.ZERO


func _ready() -> void:
	#timer znikniecia pocisku
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(destroy_projectile)
	add_child(timer)
	timer.start()
	
	add_to_group("enemy_projectile")
	add_to_group("cleared_on_scene_change")
	connect("body_entered", _on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node) -> void:
	destroy_projectile()


func destroy_projectile():
	queue_free()
