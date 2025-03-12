extends Entity

@onready var proj_manager = get_tree().get_root().find_child("NodeEnemyProjectileManager", true, false)
@onready var currentscene = get_tree().get_root().find_child("CurrentScene", true, false)

var drop1 = {
	"item": preload("res://Resources/Items/stick.tres"),
	"max_amount": 4,
	"odds": 5 #what are the odds of dropping; here one in three
}
var drop2 = {
	"item": preload("res://Resources/Items/rope.tres"),
	"max_amount": 3,
	"odds": 5
}
var stat_multiplier

func _ready() -> void:
	#entity stats
	is_passive = false
	stat_multiplier = 0.20 * (global.player_level-1)
	health = 200 + (200*stat_multiplier)
	max_health = health
	damage = 50 + (50*stat_multiplier)
	xp_drop = 4
	
	#item drops
	drops.append(drop1)
	drops.append(drop2)
	
	#misc
	set_collisions()
	update_healthbar()
	entity_damaged.connect(update_healthbar) 
	entity_behavior = SnakeAI.new()
	entity_behavior.animation = $AnimatedSprite2D
	$AnimatedSprite2D.play("walk")


func update_healthbar():
	$Health.text = str(health) + " / " + str(max_health)
