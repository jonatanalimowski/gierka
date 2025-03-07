extends Control
@onready var slider = $PanelContainer/MarginContainer/VBoxContainer/HSlider
@onready var amount_label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var ok_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/OK
@onready var cancel_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CANCEL
var item_data

func _ready():
	ok_button.pressed.connect(on_ok_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)
	slider.value_changed.connect(on_slider_value_changed)


func show_query(passed_item_data):
	item_data = passed_item_data
	visible = true
	slider.max_value = item_data["item"].stack_size
	slider.min_value = 1
	slider.value = item_data["item"].stack_size


func on_ok_pressed():
	var inv_index = item_data["inv_index"]
	player_inventory.drop_item(inv_index, slider.value)
	visible = false


func on_cancel_pressed():
	visible = false


func on_slider_value_changed(value):
	amount_label.text = str(value)
