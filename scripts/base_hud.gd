extends  CanvasLayer
class_name CanvasLayerHUD

const audo_hud_enabled:bool = true


func _ready() -> void:
	if audo_hud_enabled: register_signals()


func register_signals():
	InputManager.camera_dragging.connect(change_visiblity)

func change_visiblity(camera_dragging:bool):
	visible = not camera_dragging
