class_name TerritoryData extends RefCounted
var center:Vector2
var coordinates:PackedVector2Array

func _init(tmpcenter:Array,tmpcoordinates:Array) -> void:
	assert(not tmpcenter.is_empty(),"why !!!")
	self.center = GeoHelper.decode_vertices(tmpcenter[0],tmpcenter[1]) if not tmpcenter.is_empty() else Vector2.ZERO
	self.coordinates = GeoHelper.decode_vertices_from_dict(tmpcoordinates)
