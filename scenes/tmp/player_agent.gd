extends CharacterBody2D

var host_country:String
var target_position:Vector2
@onready var navAgent:NavigationAgent2D  = $NavigationAgent2D
var timer:Timer = Timer.new()

func _ready() -> void:
	remove_after_reaching_target()
	remove_if_unreachable()
	make_beeping()

	# can't set navAgent target in _ready first frame. hot fix
	await get_tree().physics_frame
	navAgent.target_position = target_position


func _physics_process(_delta: float) -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	if navAgent.is_navigation_finished():
		return
	var next_path_pos:Vector2 = navAgent.get_next_path_position()
	velocity = global_position.direction_to(next_path_pos) * 50
	move_and_slide()


func make_beeping() -> void:
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = 1000
	timer.timeout.connect(func () -> void:
		$Circle.visible = not $Circle.visible
		)
	add_child(timer)


func remove_after_reaching_target():
		navAgent.target_reached.connect(func ():
			get_tree().create_timer(2).timeout.connect(func ():
				ArmyManager.remove_agent(self)
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


func entered_territory(country_id:String,make_warn:Callable):
	if World.is_country_enemy(country_id):
		make_warn.call(10,global_position,host_country)
