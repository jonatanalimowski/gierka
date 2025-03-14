extends CharacterBody2D

@onready var tilemap = get_tree().get_root().find_child("TileMapLayer", true, false)
@onready var proj_manager = get_tree().get_root().find_child("player_projectile_manager", true, false)
@onready var dash_duration = $DashDuration
@onready var dash_cooldown = $DashCooldown

@onready var dash_speed = walk_speed*3
@onready var character_speed = walk_speed
@export var max_health := 100
@export var health := 100
@export var walk_speed := 200
@export var damage: int = 50
@export var armor: int = 5
@export var obszar_przeszukiwan := 3

var can_dash: bool = true
var is_invincible: bool = false
var invincibility_seconds: float = 0.5
var default_on_click_behavior = ItemBehaviorMelee.new()
var current_on_click_behavior: ItemBehavior = null


func _ready() -> void:
	dash_cooldown.timeout.connect(func(): can_dash = true)
	dash_duration.timeout.connect(dash_finished)
	global.player_stat_update.connect(update_stats) 
	global.toolbar_chosen_item_changed.connect(item_in_hand_changed)
	current_on_click_behavior = default_on_click_behavior
	update_stats()
	add_to_group("player")
	if not tilemap:
		print("TileMapLayer nie znaleziony przez gracza")
	if not proj_manager:
		print("gracz nie widzi proj_managera")


func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * character_speed
	move_and_slide()
	
	chunk_loader.check_if_player_crossed_chunks(global_position)


func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		var building_node = $InteractionArea.closest_building_node
		if is_instance_valid(building_node):
			if building_node.has_method("open_ui"):
				building_node.open_ui()
			elif building_node.has_method("interact"):
				building_node.interact()
	
	if event.is_action_pressed("shoot"):
		current_on_click_behavior.on_use(self, get_global_mouse_position(), damage)
		#if not is_instance_valid(proj_manager):
		#	proj_manager = get_tree().get_root().find_child("player_projectile_manager", true, false)
		#else:
		#	proj_manager._on_shoot(damage)
	
	if event.is_action_pressed("dash"):
		if can_dash:
			character_speed = dash_speed
			is_invincible = true
			can_dash = false
			dash_duration.start()
			dash_cooldown.start()
			global.emit_signal("player_dashed", dash_cooldown.wait_time)
	
	
	if event.is_action_pressed("wheel_up"):
		if $Camera2D.zoom <= Vector2(1.5, 1.5):
			$Camera2D.zoom *= 1.15
	
	if event.is_action_pressed("wheel_down"):
		if $Camera2D.zoom >= Vector2(0.1, 0.1):#Vector2(0.9, 0.9):
			$Camera2D.zoom /= 1.15


func dash_finished():
	is_invincible = false
	character_speed = walk_speed


func item_in_hand_changed(item):
	if item != null:
		if item.usable_item == true:
			current_on_click_behavior = item.item_behavior
		else:
			current_on_click_behavior = default_on_click_behavior
	else:
		current_on_click_behavior = default_on_click_behavior


func check_tiles_for_interaction(): #rly old method
	var interactive_tiles = [] #zwracane kafelki
	if not is_instance_valid(tilemap):
		tilemap = get_tree().get_root().find_child("TileMapLayer", true, false)
	var przekatna_obszaru = obszar_przeszukiwan - 2
	var poz_kafelkowa_rog = tilemap.local_to_map(global_position)-Vector2i(przekatna_obszaru,przekatna_obszaru)
	
	for i in range(obszar_przeszukiwan): #DODAC SPRAWDZANIE CZY GRACZ NIE JEST POZA MAPA
		for j in range(obszar_przeszukiwan):
			var tile_rodzaj = poz_kafelkowa_rog+Vector2i(i,j)
			var tile_data = tilemap.get_cell_tile_data(tile_rodzaj)
			if tile_data.get_custom_data("interaction"):
				interactive_tiles.append(tile_data.get_custom_data("interaction"))
	
	if interactive_tiles != []:
		return interactive_tiles[0]


func take_damage(damage):
	if not is_invincible:
		var dmg_mitigation = float(armor)/float(100+armor)
		var effective_dmg = damage*(1-dmg_mitigation) #1-dmg_mitigation to ile% redukuje 200 armor to 2/3 sa redukowane, czli 1/3 effective obrazenia
		global.change_sprite_color(self)
		global.player_current_health -= effective_dmg
		global.emit_signal("player_health_changed")
		if global.player_current_health <= 0:
			die()
		else: #inv-frames
			is_invincible = true
			await get_tree().create_timer(invincibility_seconds).timeout
			is_invincible = false


func die():
	world_state.clear_instanced_objects()
	player_inventory.drop_inventory()
	global.player_current_health = global.player_max_health
	global_position = global.player_spawn
	global.player_money = 0
	global.emit_signal("player_stat_update")


func update_stats():
	max_health = global.player_max_health
	health = global.player_current_health
	damage = global.player_damage
	walk_speed = global.player_speed
	dash_speed = walk_speed*3
	character_speed = walk_speed
	armor = global.player_armor
	global.emit_signal("player_health_changed")
