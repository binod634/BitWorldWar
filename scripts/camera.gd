extends Camera2D

@export var pan_speed :=1
var dragging := false
var last_pos := Vector2.ZERO
var interpolation_disabled:bool = false

func _unhandled_input(event):
	if event is InputEventMagnifyGesture:
		var to_zoom = event.factor * zoom
		if to_zoom.x < Game.min_zoom: return
		if to_zoom.x > Game.max_zoom:return
		zoom = to_zoom

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if not dragging && event.position == last_pos:
				ArmyManager.got_location_point(get_global_mouse_position())
			last_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if zoom.x/1.05 < Game.min_zoom: return
			zoom /=1.05
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if zoom.x*1.05 > Game.max_zoom: return
			zoom *=1.05


	elif event is InputEventMouseMotion and dragging:
		var diff_position:Vector2 = event.position - last_pos
		global_position -= diff_position * pan_speed/zoom
		last_pos = event.position



func _physics_process(_delta: float)  -> void:
	if interpolation_disabled:
		physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_INHERIT
		interpolation_disabled = false
	if position.x < 0 || position.x > Game.resolution.x:
		physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		interpolation_disabled = true
		position.x = wrapf(position.x, 0, Game.resolution.x)
