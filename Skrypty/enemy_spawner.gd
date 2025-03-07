extends Node2D

@export var enemy_slime: PackedScene
@onready var player = get_tree().get_root().find_child("player", true, false)
@onready var tilemap = get_tree().get_root().find_child("TileMapLayer", true, false)
@onready var currentscene = get_tree().get_root().find_child("CurrentScene", true, false)
@onready var spawn_timer = Timer.new()
@onready var cull_timer = Timer.new()
var collidable_tiles = [Vector2i(1,1), Vector2i(1,2), Vector2i(2,1), Vector2i(3, 2)]
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	if player:
		print("Enemy spawner widzi gracza")
	else:
		print("!!Enemy spawner nie widzi gracza")
		
	if tilemap:
		print("TileMapLayer znaleziony przez enemy spawner")
	else:
		print("!!TileMapLayer nie znaleziony przez enemy spawner")
	if currentscene:
		print("Enemy spawner widzi currentscene")
	else:
		print("!!Enemy spawner nie widzi currentscene")
	
	#spawn timer
	spawn_timer.timeout.connect(spawn_entity)
	spawn_timer.wait_time = 2
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


func spawn_entity(): #should be entity in function parameters
	if global.enemy_entities_on_screen <= 30: #TEMP
		var entity = enemy_slime.instantiate() #TEMP
		if is_instance_valid(player):
			if is_instance_valid(tilemap):
				var spawn_position = get_spawn_position()
				while tilemap.get_cell_atlas_coords(spawn_position) in collidable_tiles:
					spawn_position = get_spawn_position()
					
				entity.global_position = tilemap.map_to_local(spawn_position)
				currentscene.add_child(entity)
				#print("spawned at", tilemap.map_to_local(spawn_position))
				global.enemy_entities_on_screen += 1 #TEMP???
				
			else:
				tilemap = get_tree().get_root().find_child("TileMapLayer", true, false)
		else:
			player = get_tree().get_root().find_child("player", true, false)


func cull_enemies():
	if player:
		for entity in get_tree().get_nodes_in_group("enemy"):
			if entity.global_position.distance_to(player.global_position) >= 3500: #cull distance
				entity.queue_free()


func get_spawn_position():
	if is_instance_valid(player):
		if is_instance_valid(tilemap):
			var viewport = get_viewport_rect()
			var screen_size = viewport.size
			var player_position = player.global_position
			var direction = Vector2.RIGHT.rotated(randf() * TAU)  #random direction
			var spawn_distance = screen_size.length() * randf_range(1, 1.2)  #makes it offscreen
			return tilemap.local_to_map(player_position + direction * spawn_distance) #centers it on the closest valid tile
			
		else:
			tilemap = get_tree().get_root().find_child("TileMapLayer", true, false)
	else:
		player = get_tree().get_root().find_child("player", true, false)
