extends Node2D

@onready var navAgent := $"../NavigationAgent2D"
var timer:Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	navAgent.target_position = Vector2(1200,700)
	
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



func _use_agent():
	print(navAgent.get_current_navigation_path())
