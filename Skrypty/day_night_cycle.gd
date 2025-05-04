extends CanvasModulate

const ingame_day_length = 2*PI
const minutes_in_day: int = 1440
const minutes_in_hour: int = 60
const ingame_to_real_minute_duration = ingame_day_length / minutes_in_day

@export var gradient: GradientTexture1D
var time = 0
var current_day = 1
var current_hour = 12
var current_minute = 0


func _ready() -> void:
	time = ingame_to_real_minute_duration * current_hour * minutes_in_hour
	global.time_updated.emit(current_day, current_hour, current_minute)


func _process(delta: float) -> void:
	time += delta / 20
	
	var value = (sin(time - PI / 2) + 1.0) / 2.0 #przesuwa funkcje sinus z [-1, 1] na [0, 1]
	color = gradient.gradient.sample(value)
	
	update_current_time()


func update_current_time():
	var total_minutes = floori(time / ingame_to_real_minute_duration)
	current_day = total_minutes / minutes_in_day
	current_hour = (total_minutes / minutes_in_hour) % (minutes_in_day/minutes_in_hour)
	current_minute = total_minutes%minutes_in_hour
	global.time_updated.emit(current_day, current_hour, current_minute)
