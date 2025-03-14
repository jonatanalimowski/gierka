extends Area2D

var closest_building_node
var buildings_in_area_data = []


func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)


func _on_body_entered(body):
	pass


func _on_body_exited(body):
	pass


func _on_area_entered(area):
	if area.is_in_group("building_interaction"):
		var building_node = area.get_parent()
		var building_data = {
			"position": building_node.global_position,
			"building_node": weakref(building_node) #weakref robi ze jak bedzie blad i przypisze node ktorego nie ma to bedzie null, a nie freed object
		}
		buildings_in_area_data.append(building_data)
		update_closest()


func update_closest():
	var smallest_distance = INF
	var temp_node_container = null
	for building_data in buildings_in_area_data.duplicate():
		var node_ref = building_data["building_node"].get_ref()
		if node_ref == null:
			buildings_in_area_data.erase(building_data)
			continue
	
		building_data["position"] = node_ref.global_position
		var distance_to_player = building_data["position"].distance_to(self.global_position)
		if distance_to_player < smallest_distance:
			smallest_distance = distance_to_player
			temp_node_container = node_ref
			
	if is_instance_valid(closest_building_node):
		closest_building_node.toggle_popup()
	closest_building_node = temp_node_container
	if is_instance_valid(closest_building_node):
		closest_building_node.toggle_popup()


func _on_area_exited(area):
	if area.is_in_group("building_interaction"):
		var building_node = area.get_parent()
		for building_data in buildings_in_area_data.duplicate():
			if building_data["building_node"].get_ref() == building_node:
				buildings_in_area_data.erase(building_data)
				break
		update_closest()
		global.emit_signal("close_building_ui")
