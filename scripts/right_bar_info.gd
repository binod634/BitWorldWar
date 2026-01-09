extends CanvasLayer

@export var AutoHide:bool = true
@onready var SizeThemeBox:Control = $SizeTheme


func _ready() -> void:
	if AutoHide:
		get_tree().create_timer(2).timeout.connect(set_tween)


func set_tween():
	var tween = get_tree().create_tween()
	tween.tween_property(SizeThemeBox,^'modulate',Color.TRANSPARENT,0.5)


func _hide_self():
	visible = false
