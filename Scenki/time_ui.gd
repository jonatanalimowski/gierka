extends Control


func _ready() -> void:
	global.time_updated.connect(on_time_update)


func on_time_update(day, hour, minute):
	$PanelContainer/MarginContainer/VBoxContainer/Day.text = "Day: " + str(day)
	$PanelContainer/MarginContainer/VBoxContainer/Hour.text = "Hour: " + str(hour)
	$PanelContainer/MarginContainer/VBoxContainer/Minute.text = "Minute: " + str(minute)
