extends BaseUnit
class_name LandUnit
#
#@export var nav_agent: NavigationAgent2D
#@export var speed: float = 150.0
#var target_pos: Vector2
#
#func _ready() -> void:
	#super._ready()
	#assert(nav_agent,"Really ? no navagent")
#
#
#func _physics_process(_delta):
	#if nav_agent.is_navigation_finished():return
#
	#var next_path_pos = nav_agent.get_next_path_position()
	#var direction = global_position.direction_to(next_path_pos)
	#velocity = direction * speed
	#move_and_slide()
#
	## Rotate the visual character node
	#character_texture.rotation = direction.angle()
#
#func move_to(goal: Vector2):
	#nav_agent.target_position = goal
