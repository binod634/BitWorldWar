extends  CanvasLayer
class_name CanvasLayerHUD

func _ready() -> void:
	register_signals()


func register_signals():
	InputManager.camera_dragging.connect(change_visiblity)

func change_visiblity(camera_dragging:bool):
	visible = not camera_dragging
