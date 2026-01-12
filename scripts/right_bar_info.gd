extends CanvasLayer

@onready var country_label_node:Label = $SizeTheme/HBoxContainer/Control/MarginContainer/VBoxContainer/HBoxContainer/Country
var country_id:String = ""
var country_name:String = "":
	set(value):
		country_name = value
		if country_label_node:
			country_label_node.text = value


func set_country_data(data:CountryData):
	country_name =  data.country_name
	country_id = data.country_id

func declare_war_clicked():
	RelationManager.declare_war_on(country_id)


func alliance_button_clicked() -> void:
	RelationManager.make_friendly_country(country_id)
