extends Node

var selected_nation_id:String



func select_nation(nation_id:String) -> void:
	selected_nation_id = nation_id

func is_country_mine(query_id:String):
	return query_id == selected_nation_id
