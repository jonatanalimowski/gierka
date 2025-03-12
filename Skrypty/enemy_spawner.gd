extends Node2D

var ads: Array
@export var enemy_slime: PackedScene
@export var enemy_snake: PackedScene
@onready var player = get_tree().get_root().find_child("player", true, false)
@onready var tilemap = get_tree().get_root().find_child("TileMapLayer", true, false)
@onready var currentscene = get_tree().get_root().find_child("CurrentScene", true, false)
@onready var spawn_timer = Timer.new()
@onready var cull_timer = Timer.new()
var collidable_tiles = [Vector2i(1,1), Vector2i(1,2), Vector2i(2,1), Vector2i(3, 2)]
var rng = RandomNumberGenerator.new()

@onready var biome_spawns = {
	"Forest": [enemy_slime],
	"Dunes": [enemy_snake, enemy_slime],
	"Tundra": [enemy_slime]
}


func _ready() -> void:
	if not player:
		print("!!Enemy spawner nie widzi gracza")
	
	if not tilemap:
		print("!!TileMapLayer nie znaleziony przez enemy spawner")
	
	if not currentscene:
		print("!!Enemy spawner nie widzi currentscene")
	
	#spawn timer
	spawn_timer.timeout.connect(spawn_entity)
	spawn_timer.wait_time = 0.2
	spawn_timer.autostart = true
	add_child(spawn_timer)
	print(spawn_timer)
	
	#cull timer
	cull_timer.timeout.connect(cull_enemies)
	cull_timer.wait_time = 10
	cull_timer.autostart = true
	add_child(cull_timer)
	cull_timer.start()


func _process(delta: float) -> void:
	pass


func spawn_entity():
	if global.enemy_entities_alive <= 10:
		if is_instance_valid(player):
			if is_instance_valid(tilemap):
				#decides which enemy
				var spawn_position = get_spawn_position()
				var biome = chunk_loader.get_chunk_biome(tilemap.map_to_local(spawn_position))
				var entity = biome_spawns[biome].pick_random().instantiate()
				while tilemap.get_cell_atlas_coords(spawn_position) in collidable_tiles:
					spawn_position = get_spawn_position()
					biome = chunk_loader.get_chunk_biome(tilemap.map_to_local(spawn_position))
					entity = biome_spawns[biome].pick_random().instantiate()
				#print("spawning: ", entity.name, " at: ", biome)
				entity.global_position = tilemap.map_to_local(spawn_position)
				currentscene.add_child(entity)
				#print("spawned at", tilemap.map_to_local(spawn_position))
				global.enemy_entities_alive += 1
				
			else:
				tilemap = get_tree().get_root().find_child("TileMapLayer", true, false)
		else:
			player = get_tree().get_root().find_child("player", true, false)


func cull_enemies():
	if player:
		for entity in get_tree().get_nodes_in_group("enemy"):
			if entity.global_position.distance_to(player.global_position) >= 2500: #cull distance
				entity.queue_free()
				global.enemy_entities_alive -= 1


func get_spawn_position():
	if is_instance_valid(player):
		if is_instance_valid(tilemap):
			var player_position = player.global_position
			var direction = Vector2.RIGHT.rotated(randf() * TAU)  #random direction; TAU is circle constant in radians
			var spawn_distance = Vector2(1, 1) * randf_range(1000, 1500)  #dist
			return tilemap.local_to_map(player_position + direction * spawn_distance) #centers it on the closest valid tile
			
		else:
			tilemap = get_tree().get_root().find_child("TileMapLayer", true, false)
	else:
		player = get_tree().get_root().find_child("player", true, false)
		
