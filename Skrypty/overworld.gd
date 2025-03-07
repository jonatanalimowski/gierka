extends Node2D

func _ready() -> void:
	$TileMapLayer.z_index = -1
	chunk_loader.tilemap = $TileMapLayer
	global.connect("player_spawn_ready", set_player_spawn)


func set_player_spawn(pos):
	global.player_spawn = pos
	$player.global_position = pos
