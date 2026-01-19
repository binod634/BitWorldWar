class_name BuildingModel extends RefCounted

var building_type:BuildingData
var current_level:int

func _init(type:BuildingData,level:int = 1) -> void:
	building_type = type
	current_level = level

func increase_building_level():
	assert(current_level <= building_type.max_level)
	if current_level < building_type.max_level:
		current_level +=1


func is_max_leveled():
	return current_level == building_type.max_level
