extends Node

# signals
signal prompt_building_placement



enum InputModes {None,Placement,}
var currentMode:InputModes = InputModes.None



func _unhandled_input(event: InputEvent) -> void:
		if currentMode == InputModes.Placement:
			pass



func signal_placement():
	currentMode = InputModes.Placement
	prompt_building_placement.emit()
