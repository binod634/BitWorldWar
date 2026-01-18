extends Node

# signals
signal prompt_building_placement
signal camera_dragging(status:bool)
signal camera_level_changed(level:CameraData)

# signal router
func signal_camera_level(level:CameraData): camera_level_changed.emit(level)
func signal_camera_dragging(status:bool): camera_dragging.emit(status)



enum InputModes {None,Placement,}
var currentMode:InputModes = InputModes.None



func _unhandled_input(event: InputEvent) -> void:
		if currentMode == InputModes.Placement:
			pass



func signal_placement():
	currentMode = InputModes.Placement
	prompt_building_placement.emit()
