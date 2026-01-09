extends CanvasLayer

@export var AutoHide:bool = true

func _ready() -> void:
	if AutoHide:
		get_tree().create_timer(5).timeout.connect(_hide_self)

func _hide_self():
	visible = false
