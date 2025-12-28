extends CharacterBody2D

var host_country:String
var target_position:Vector2
@onready var navAgent:NavigationAgent2D  = $NavigationAgent2D
var timer:Timer = Timer.new()

func _ready() -> void:
	remove_after_reaching_target()
	remove_if_unreachable()
	make_beeping()
	navAgent.target_position = target_position


func _physics_process(_delta: float) -> void:
	if navAgent.is_navigation_finished():
		return
	var next_path_pos = navAgent.get_next_path_position()
	velocity = (next_path_pos - global_position).normalized() * 50
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
				Game.remove_agent(self)
			)
		)

func remove_if_unreachable():
	get_tree().create_timer(5).timeout.connect(func ():
		if not navAgent.is_target_reachable():
			Game.remove_agent(self)
		)


func am_i_hostile(hashed_name:String) -> bool:
	return Game.is_country_enemy(hashed_name)


func check_enough_power_to_conquer():
	return true
