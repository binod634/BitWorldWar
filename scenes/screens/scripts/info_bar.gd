extends CanvasLayerHUD



func _ready() -> void:
	visible = false
	super._ready()
	WorldManager.info_bar_visiblity_changed.connect(change_visiblity)
