extends Camera2D

@export var pan_speed :=1
const max_zoom:float = 30.0
const min_zoom:float = 4.0

var dragging := false
var last_pos := Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMagnifyGesture:
		#print("pan working: %s"%[event.factor])
		var to_zoom = event.factor * zoom
		print("zoom scale is: %s"%[zoom])
		if to_zoom.x < min_zoom: return
		if to_zoom.x > max_zoom:return
		zoom = to_zoom
			
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if zoom.x/1.05 < min_zoom/2: return
			zoom /=1.05
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if zoom.x*1.05 > max_zoom: return
			zoom *=1.05
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("reloaded")
			get_tree().reload_current_scene()
			
	elif event is InputEventMouseMotion and dragging:
		var delta :Vector2 = event.position - last_pos
		global_position -= delta * pan_speed/zoom
		last_pos = event.position
