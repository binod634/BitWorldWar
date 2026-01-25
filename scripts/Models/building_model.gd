class_name BuildingModel extends RefCounted


var building_type:BuildingData
var current_level:int
var is_active:bool = false
var remaining_time:float = 0
var current_production_queue:int = 0
var isInfinite:bool = false

func _init(type:Game.BuildingType,level:int = 1) -> void:
	building_type = Game.buildings[type]
	current_level = level

func increase_building_level():
	assert(current_level <= building_type.max_level)
	if current_level < building_type.max_level:
		current_level +=1


func is_max_leveled():
	return current_level == building_type.max_level
