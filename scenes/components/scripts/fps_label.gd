extends Label


var timer:Timer = Timer.new()
const check_second:float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = check_second
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_process_fps)
	add_child(timer)
	
func _process_fps():
	var fps:float = Engine.get_frames_per_second()
	text = "FPS: " + str(fps)
