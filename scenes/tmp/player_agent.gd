extends CharacterBody2D

var host_country:String
var target_position:Vector2
@onready var navAgent:NavigationAgent2D  = $NavigationAgent2D
var timer:Timer = Timer.new()

func _ready() -> void:
	remove_after_reaching_target()
	make_beeping()
	navAgent.target_position = target_position


func _physics_process(_delta: float) -> void:
	if navAgent.is_navigation_finished():
		return
	var next_path_pos = navAgent.get_next_path_position()
	var new_velocity = (next_path_pos - global_position).normalized() * 20
	velocity = new_velocity
	move_and_slide()


func make_beeping():
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 0.25
	timer.timeout.connect(func ():
		$Circle.visible = not $Circle.visible
		)
	add_child(timer)


func remove_after_reaching_target():
		navAgent.target_reached.connect(func ():
			get_tree().create_timer(2).timeout.connect(func ():
				Game.remove_agent(name)
				queue_free()
			)
		)

func entered_nation(hashed_name:String):
	if Game.is_country_enemy(hashed_name):
		pass

func am_i_hostile(hashed_name:String) -> bool:
	return Game.is_country_enemy(hashed_name)


func get_power_level() -> float:
	return 100.0
