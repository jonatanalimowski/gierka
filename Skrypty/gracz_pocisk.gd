extends Area2D

@export var speed: float = 400.0
@export var damage: float
var direction := Vector2.ZERO


func _ready() -> void:
	add_to_group("cleared_on_scene_change")
	connect("body_entered", _on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	else:
		queue_free()
