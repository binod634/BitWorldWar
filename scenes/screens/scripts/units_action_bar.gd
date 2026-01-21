extends CanvasLayerHUD

func _ready() -> void:
	super._ready()
	register_signals()

func register_signals() -> void:
	ArmyManager.show_army_command.connect(_on_show_army_command)

func _on_show_army_command(status: bool) -> void:
	visible = status

func _on_attack_toggled(toggled_on: bool) -> void:
	ArmyManager.change_to_attack_mode(toggled_on)


func _on_move_toggled(toggled_on: bool) -> void:
	ArmyManager.change_to_move_mode(toggled_on)
