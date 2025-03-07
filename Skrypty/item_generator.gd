extends Node

const base_path = "res://Teksturki/"

const item_texture_folders = {
	"weapon": "weapon_textures/",
	"head_armor": "head_armor_textures/",
	"chest_armor": "chest_armor_textures/",
	"leg_armor": "leg_armor_textures/",
	"boots": "boots_textures/",
	"misc": "misc_item_textures/"
}

const textures = {
	"weapon": [
		"res://Teksturki/weapon_textures/frog_weapon.png",
		"res://Teksturki/weapon_textures/mieczyk_pysio.png"
	],
	"head_armor": [
		"res://Teksturki/head_armor_textures/helm1.png",
		"res://Teksturki/head_armor_textures/helm2.png",
		"res://Teksturki/head_armor_textures/helm3.png",
		"res://Teksturki/head_armor_textures/frog_helmet.png"
	],
	"chest_armor": [
		"res://Teksturki/chest_armor_textures/body1.png",
		"res://Teksturki/chest_armor_textures/body2.png",
		"res://Teksturki/chest_armor_textures/frog_chest_armor.png"
	],
	"leg_armor": [
		"res://Teksturki/leg_armor_textures/frog_leg_armor.png"
	],
	"boots": [
		"res://Teksturki/boots_textures/frog_boots.png"
	],
	"misc": [
		"res://Teksturki/misc_item_textures/stick_texture.png",
		"res://Teksturki/misc_item_textures/rope_texture.png"
	]
}

const item_names = {
	"res://Teksturki/boots_textures/frog_boots.png": "Frog Boots",
	"res://Teksturki/chest_armor_textures/body1.png": "Abyssal Chestplate",
	"res://Teksturki/chest_armor_textures/body2.png": "Deathbringer Chestplate",
	"res://Teksturki/chest_armor_textures/frog_chest_armor.png": "Frog Chestplate",
	"res://Teksturki/head_armor_textures/helm1.png": "Skull of the Fallen Lich",
	"res://Teksturki/head_armor_textures/helm2.png": "Deathbringer Helmet",
	"res://Teksturki/head_armor_textures/helm3.png": "Abyssal Mask",
	"res://Teksturki/head_armor_textures/frog_helmet.png": "Frog Helmet",
	"res://Teksturki/leg_armor_textures/frog_leg_armor.png": "Frog Pants",
	"res://Teksturki/weapon_textures/frog_weapon.png": "Frog Staff",
	"res://Teksturki/weapon_textures/mieczyk_pysio.png": "Pookie Sword",
	"res://Teksturki/misc_item_textures/stick_texture.png": "Stick",
	"res://Teksturki/misc_item_textures/rope_texture.png": "Rope"
}

const item_descriptions = {
	"res://Teksturki/boots_textures/frog_boots.png": "temp",
	"res://Teksturki/chest_armor_textures/body1.png": "temp",
	"res://Teksturki/chest_armor_textures/body2.png": "temp",
	"res://Teksturki/chest_armor_textures/frog_chest_armor.png": "temp",
	"res://Teksturki/head_armor_textures/helm1.png": "temp",
	"res://Teksturki/head_armor_textures/helm2.png": "temp",
	"res://Teksturki/head_armor_textures/helm3.png": "temp",
	"res://Teksturki/head_armor_textures/frog_helmet.png": "temp",
	"res://Teksturki/leg_armor_textures/frog_leg_armor.png": "temp",
	"res://Teksturki/weapon_textures/frog_weapon.png": "temp",
	"res://Teksturki/weapon_textures/mieczyk_pysio.png": "temp",
	"res://Teksturki/misc_item_textures/stick_texture.png": "A wooden stick",
	"res://Teksturki/misc_item_textures/rope_texture.png": "A piece of rope"
}

const item_stats: Array = ["damage", "armor", "health", "speed"]


func get_random_texture_for_type(item_type):
	var textures_list = textures.get(item_type, [])
	return textures_list[randi() % textures_list.size()] if textures_list.size() > 0 else "res://missing_texture.png"


func generate_random_eq_item(item_type) -> Item:
	if item_type == null:
		while item_type == null or item_type == "misc":
			item_type = pick_random_from_dict(item_texture_folders)
	var new_item = Item.new()
	var texture = get_random_texture_for_type(item_type)
	
	new_item.texture = load(texture)
	new_item.name = get_item_name_and_desc(texture).get("name")
	new_item.description = get_item_name_and_desc(texture).get("description")
	
	new_item.slot = item_type
	new_item.level_req = max(1, global.player_level + randi_range(-2, 2))
	
	roll_for_stats(new_item, new_item.level_req)
	
	return new_item


func generate_random_misc_item(amount):
	var item_type = "misc"
	var new_item = Item.new()
	var texture = get_random_texture_for_type(item_type)
	
	new_item.texture = load(texture)
	new_item.name = get_item_name_and_desc(texture).get("name")
	new_item.description = get_item_name_and_desc(texture).get("description")
	
	new_item.equipment_item = false
	new_item.slot = "resource"
	new_item.stackable = true
	if amount:
		new_item.stack_size = amount
	else:
		new_item.stack_size = randi_range(1,3)
	
	return new_item


func pick_random_from_dict(dictionary: Dictionary) -> Variant:
	var random_key = dictionary.keys().pick_random()
	return random_key


func roll_for_stats(item, level_req):
	var stat_number = item_stats.size()
	var stats_upgraded: Array = []

	for i in range(randi_range(1, stat_number)):
		var stat = item_stats[randi()%stat_number]
		if stat not in stats_upgraded:
			stats_upgraded.append(stat)
			var roll_result = randi_range(1, level_req+1)
			var stat_value = roll_result * randi_range(1, level_req+1)
			item[stat] = stat_value + 10


func get_item_name_and_desc(texture_path) -> Dictionary:
	return {
		"name": item_names.get(texture_path, "Unknown Item"),
		"description": item_descriptions.get(texture_path, "A mysterious artifact with no known history.")
	}
