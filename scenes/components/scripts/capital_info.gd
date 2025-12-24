extends Node2D

var country_name:String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = country_name
