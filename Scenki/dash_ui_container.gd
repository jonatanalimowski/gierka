extends HBoxContainer
@onready var dash_progress_bar = $DashCooldown
@onready var dash_timer = Timer.new()

func _ready() -> void:
	global.player_dashed.connect(on_player_dash)
	dash_timer.one_shot = true
	dash_progress_bar.value = dash_progress_bar.max_value
	add_child(dash_timer)


func _process(delta: float) -> void:
	dash_progress_bar.value = (dash_timer.wait_time - dash_timer.time_left)*100


func on_player_dash(dash_cooldown):
	dash_progress_bar.max_value = dash_cooldown*100
	dash_timer.wait_time = dash_cooldown
	dash_timer.start()
