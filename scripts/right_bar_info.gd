extends CanvasLayer

@export var AutoHide:bool = false
@onready var SizeThemeBox:Control = $SizeTheme
@onready var country_label_node:Label = $SizeTheme/HBoxContainer/Control/MarginContainer/VBoxContainer/HBoxContainer/Country
var country_name:String = "":
	set(value):
		country_name = value
		if country_label_node:
			country_label_node.text = value


func _ready() -> void:
	if AutoHide:
		get_tree().create_timer(2).timeout.connect(set_tween)



func set_tween():
	var tween = get_tree().create_tween()
	tween.tween_property(SizeThemeBox,^'modulate',Color.TRANSPARENT,0.5)



func set_country_data(data:CountryData):
	country_name =  data.country_name
