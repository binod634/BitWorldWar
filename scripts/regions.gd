extends Node2D

@onready var navAgent := $"../NavigationAgent2D"
var to_position:Vector2  = Vector2.ZERO
var timer:Timer = Timer.new()

func _ready() -> void:
	navAgent.target_position = Vector2(100,100)

	await get_tree().process_frame
	_use_agent()
	print(navAgent.is_target_reachable())
	print(navAgent.is_target_reached())
	timer.timeout.connect(_use_agent)
	timer.wait_time = 0.1
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.

#
#func _unhandled_input(event: InputEvent) -> void:
	#if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		#if event.is_pressed():
			#var mouse_pos_world = get_viewport().get_camera_2d().get_global_mouse_position()
			#navAgent.target_position = mouse_pos_world
			#to_position = mouse_pos_world
			#print("pressed %s"%[navAgent.is_target_reachable()])


func _use_agent():
	#print("path: %s length: %s"%[ navAgent.get_next_path_position(),navAgent.get_path_length() ])
	pass
