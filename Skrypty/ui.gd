extends Control

@onready var base_ui = $BaseUI
@onready var pause_ui = $PauseUI
@onready var lvl_up_ui = $LevelUpUI
@onready var stats_ui = $StatisticsUI
@onready var inv_ui = $InventoryUI
@onready var inv_ui_inv_grid = $InventoryUI/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/inv_grid
@onready var inv_ui_eq_grid = $InventoryUI/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/eq_grid
@onready var main_ui = $MainUI
@onready var drop_query_ui = $InventoryUI/DropQuery
@onready var building_ui = $BaseUI/BuildingUI
signal change_scene(scene_path)

var is_paused = false
var is_inv = false
var is_player_building = false
var is_chest_ui = false

func _ready():
	global.player_leveled_up.connect(toggle_lvl_up_ui)
	global.player_health_changed.connect(on_health_changed)
	global.player_xp_changed.connect(on_xp_changed)
	global.player_stat_update.connect(update_stats)
	global.inventory_updated.connect(fill_and_update_inventory_ui)
	
	#main_ui
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/HealthBar.value = global.player_max_health
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/HealthBar.max_value = global.player_max_health
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/LvlText.text = "Player Level: " + str(global.player_level)
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/TextureProgressBar/XpText.text = "XP: " + str(global.player_experience) + "/" + str(global.new_level_threshhold)
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/TextureProgressBar.value = global.player_experience
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/TextureProgressBar.max_value = global.new_level_threshhold
	
	#pause_ui
	$PauseUI/VBoxContainer/Button_Resume.pressed.connect(toggle_pause)
	
	#lvl_up_ui
	$LevelUpUI/HBoxContainer/OptionHP/ButtonHP.pressed.connect(health_up)
	$LevelUpUI/HBoxContainer/OptionDMG/ButtonDMG.pressed.connect(damage_up)
	$LevelUpUI/HBoxContainer/OptionSPD/ButtonSPD.pressed.connect(speed_up)
	$LevelUpUI/HBoxContainer/OptionARM/ButtonARM.pressed.connect(armor_up)
	
	#statistics_ui
	update_stats()
	
	pause_ui.visible = false
	lvl_up_ui.visible = false
	stats_ui.visible = true
	inv_ui.visible = false
	main_ui.visible = true
	drop_query_ui.visible = false
	building_ui.visible = false


func update_stats():
	$StatisticsUI/PanelContainer/MarginContainer/VBoxContainer/LabelDMG.text = "Player damage: " + str(global.player_damage)
	$StatisticsUI/PanelContainer/MarginContainer/VBoxContainer/LabelSPD.text = "Player speed: " + str(global.player_speed)
	$StatisticsUI/PanelContainer/MarginContainer/VBoxContainer/LabelARMR.text = "Player armor: " + str(global.player_armor)


func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()
	
	if event.is_action_pressed("inventory"):
		open_inv_ui()
	
	if event.is_action_pressed("build_mode_toggle"):
		toggle_building_ui()


func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_ui.visible = is_paused


func toggle_lvl_up_ui():
	is_paused = !is_paused
	get_tree().paused = is_paused
	lvl_up_ui.visible = is_paused


func health_up():
	global.player_max_health += 50
	global.player_current_health += 50
	toggle_lvl_up_ui()
	global.emit_signal("player_stat_update")



func damage_up():
	global.player_damage += 25
	toggle_lvl_up_ui()
	global.emit_signal("player_stat_update")


func speed_up():
	global.player_speed += 50
	toggle_lvl_up_ui()
	global.emit_signal("player_stat_update")


func armor_up():
	global.player_armor += 5
	toggle_lvl_up_ui()
	global.emit_signal("player_stat_update")


func on_health_changed():
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/HealthBar/HealthText.text = "HP: " + str(global.player_current_health) + "/" + str(global.player_max_health)
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/HealthBar.max_value = global.player_max_health
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/HealthBar.value = global.player_current_health


func on_xp_changed():
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/LvlText.text = "Player Level: " + str(global.player_level)
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/TextureProgressBar/XpText.text = "XP: " + str(global.player_experience) + "/" + str(global.new_level_threshhold)
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/TextureProgressBar.value = global.player_experience
	$MainUI/TopUI/PanelContainer/MarginContainer/VBoxContainer/TextureProgressBar.max_value = global.new_level_threshhold


func fill_and_update_inventory_ui(item_container = null):
	if is_inv:
		var slot_scene = preload("res://Scenki/inventory_slot.tscn")
		inv_ui_inv_grid.columns = 8
		for child in inv_ui_inv_grid.get_children():
			child.queue_free()

		#fill inventory
		for i in range(player_inventory.inv_size):
			var slot_instance = slot_scene.instantiate()
			var item = player_inventory.inv_array[i]
			
			if item:
				slot_instance.item_data = item
				slot_instance.change_to_item(item.texture)
				if player_inventory.slot_types.has(item.slot):
					slot_instance.is_equipment = true
			else:
				slot_instance.change_to_item(null)
				
			slot_instance.inv_index = i
			slot_instance.item_container = player_inventory
			slot_instance.is_slot_equipment = false
			inv_ui_inv_grid.add_child(slot_instance)
		
	#fill equipment
		for child in inv_ui_eq_grid.get_children():
			child.queue_free()
		
		var eq = player_inventory.equipment
		var eq_items = [eq["head_armor"], eq["chest_armor"], eq["leg_armor"], eq["boots"], eq["weapon"]]
		for item in eq_items: #equipment slots
			var slot_instance = slot_scene.instantiate()
			
			if item:
				slot_instance.is_equipped = true
				slot_instance.change_to_item(item.texture)
				slot_instance.item_data = item
				slot_instance.eq_slot = item.slot

			else:
				slot_instance.change_to_item(null)
			
			slot_instance.item_container = player_inventory
			slot_instance.is_slot_equipment = true
			inv_ui_eq_grid.add_child(slot_instance)


func open_inv_ui():
	is_inv = !is_inv
	fill_and_update_inventory_ui()
	inv_ui.visible = is_inv


func toggle_building_ui():
	is_player_building = !is_player_building
	building_ui.visible = is_player_building
