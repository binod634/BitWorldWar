extends Node2D
const width:int = 1280

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for a in range(1280 * 720 / 5):
		draw_line(Vector2(int((a*5)%width),int((a*5)/width + 10)),Vector2((a*5)%width,int((a*5)/width) + 2),Color(randf(),randf(),randf()),4)
