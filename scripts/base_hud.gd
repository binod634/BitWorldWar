extends  CanvasLayer
class_name CanvasLayerHUD

const audo_hud_enabled:bool = true


func _ready() -> void:
	if audo_hud_enabled: register_signals()


func register_signals():
	#InputManager.camera_dragging.connect(change_visiblity)
	pass

func change_visiblity(status:bool):
	visible = status
