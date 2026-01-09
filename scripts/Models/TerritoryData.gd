class_name TerritoryData extends RefCounted
var center:Array
var coordinates:PackedVector2Array


func _init(tmpcenter:Array,tmpcoordinates:Array) -> void:
	self.center = tmpcenter
	self.coordinates = GeoHelper.decode_vertices_from_dict(tmpcoordinates)
