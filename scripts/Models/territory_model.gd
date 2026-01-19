class_name TerritoryModel extends RefCounted
var center:Vector2
var coordinates:PackedVector2Array
var buildings:Array[BuildingModel]


func _init(tmpcenter:Array,tmpcoordinates:Array) -> void:
	assert(not tmpcenter.is_empty(),"why !!!")
	self.center = GeoHelper.decode_vertices(tmpcenter[0],tmpcenter[1]) if not tmpcenter.is_empty() else Vector2.ZERO
	self.coordinates = GeoHelper.decode_vertices_from_dict(tmpcoordinates)


func add_building(data:BuildingModel):
	buildings.append(data)

func remove_building(data:BuildingModel):
	buildings.erase(data)

func is_building_addable():
	if len(buildings) >= Game.max_buildings:
		assert(len(buildings) <= Game.max_buildings,"more buildings then expected!")
		return false
	return true
