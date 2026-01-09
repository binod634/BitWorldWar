extends RefCounted
class_name CountryData

var country_name:String
var country_id:String
var owned_vertices:PackedStringArray

func _init(name:String,id:String,territory_id_array:PackedStringArray) -> void:
	country_name = name
	country_id = id
	owned_vertices = territory_id_array
