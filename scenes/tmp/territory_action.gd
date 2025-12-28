extends Control

var timer:Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("my name is %s"%name)
	timer.wait_time = 5
	timer.one_shot = true
	timer.timeout.connect(remove_me)
	add_child(timer)
	timer.start()

func remove_me():
	get_tree().create_timer(5).timeout.connect(func ():
		Game.check_and_remove_exisiting_popups()
		)




func _on_mouse_entered() -> void:
	timer.stop()


func _on_mouse_exited() -> void:
	timer.start()


func _on_support_icon_pressed() -> void:
	print("pressed support icon")
	Game.make_friendly_country(name)
	queue_free()


func _on_war_icon_pressed() -> void:
	print("pressed war icon")
	Game.declare_war_on(name)
	queue_free()
