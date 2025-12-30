extends Node

var selected_nation:Dictionary = {}
var capital_name:String = "":
	get:
		return selected_nation.get("capital_name", "")
var capital_location:Vector2 = Vector2.ZERO:
	get:
		return selected_nation.get("capital_location", Vector2.ZERO)
var country_id:String = "":
	get:
		return selected_nation.get("hashed_name", "")



func select_nation(nation_data:Dictionary) -> void:
	selected_nation = nation_data

func is_country_mine(query_id:String):
	return query_id == PlayerData.country_id
