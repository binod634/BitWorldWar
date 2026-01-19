extends CanvasLayerHUD

func _ready() -> void:
	super._ready()



func _on_attack_toggled(toggled_on: bool) -> void:
	ArmyManager.change_to_attack_mode(toggled_on)
	print("attack mode %s"%[toggled_on])


func _on_move_toggled(toggled_on: bool) -> void:
	ArmyManager.change_to_move_mode(toggled_on)
	print("move mode %s"%[toggled_on])
