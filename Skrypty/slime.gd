extends Entity

@onready var proj_manager = get_tree().get_root().find_child("NodeEnemyProjectileManager", true, false)
@onready var currentscene = get_tree().get_root().find_child("CurrentScene", true, false)
var drop1 = {
	"item": preload("res://Resources/Items/stick.tres"),
	"max_amount": 3,
	"odds": 3 #what are the odds of dropping; here one in three
}

var stat_multiplier

func _ready() -> void:
	is_passive = false
	stat_multiplier = 1.25 ** (global.player_level-1)
	health = 100 * stat_multiplier
	max_health = health
	damage = 20 * stat_multiplier
	xp_drop = 5
	
	drops.append(drop1)
	set_collisions()
	update_healthbar()
	entity_damaged.connect(update_healthbar) 
	entity_behavior = SlimeAI.new()


func update_healthbar():
	$Health.text = str(health) + " / " + str(max_health)
