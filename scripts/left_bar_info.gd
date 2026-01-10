extends CanvasLayer

@export var AutoHide:bool = true
var ActionShown:bool = true:
	set(value):
		ActionShown = value
		call_deferred(&"show_hide_acions",value)
@onready var CollapseExpandNode:Control = $SizeTheme/HBoxContainer/CollapseExpand
@onready var ContentNode:Control = $SizeTheme/HBoxContainer/Content

func _ready() -> void:
	if AutoHide:
		get_tree().create_timer(5).timeout.connect(_hide_self)

func _hide_self():
	visible = false

func show_hide_acions(value:bool):
	if ContentNode:
		ContentNode.visible = value
