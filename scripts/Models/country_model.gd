extends RefCounted
class_name CountryModel

var country_name:String
var country_id:String
var is_playable:bool = false
var territories_id:PackedStringArray
var territory_color:Color
var is_owned:bool = false

func _init(name:String,id:String,territory_id_array:PackedStringArray,playable:bool) -> void:
	country_name = name
	country_id = id
	territories_id = territory_id_array
	is_playable = playable

func set_territory_color(color:Color) -> void:
	territory_color = color
