extends Node


func _ready() -> void:
	pass # Replace with function body.


func take_damage(entity_node, damage): #zrobic to jako klase standard_entity czy cos
	var health = entity_node.health
	var armor = entity_node.armor
	
	if armor and health and entity_node.has_method("die"):
		var dmg_mitigation = float(armor)/float(100+armor)
		var effective_dmg = damage*(1-dmg_mitigation) #1-dmg_mitigation to ile% redukuje 200 armor to 2/3 sa redukowane, czli 1/3 effective obrazenia
		global.change_sprite_color(self)
		global.player_current_health -= effective_dmg
		if health <= 0:
			entity_node.die()
