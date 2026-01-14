extends CanvasLayer

@export var AutoHide:bool = true
@onready var ProdHandler:Control = $SizeTheme/MainMenu/Content/Production/VBoxContainer/MarginContainer2/ProdHandler
var ActionShown:bool = true:
	set(value):
		ActionShown = value

func _ready() -> void:
	if AutoHide:
		get_tree().create_timer(5).timeout.connect(_hide_self)

func _hide_self():
	visible = false


func add_prod_tab():
	pass
