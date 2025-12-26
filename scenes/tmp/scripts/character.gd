extends CharacterBody2D

@onready var agent: NavigationAgent2D = $NavigationAgent2D
var speed := 120.0
var timer:Timer = Timer.new()

func _ready() -> void:
	agent.target_position = Vector2(1000, 700)

func _physics_process(_delta) -> void:
	if agent.is_navigation_finished():
		return

	var desired_velocity = global_position.direction_to(agent.get_next_path_position()) * speed
	agent.set_velocity(desired_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	print("velocity: %s reached?: %s"%[safe_velocity,agent.is_target_reached()])
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			if event.pressed:
				agent.target_position = [
					$"../markers/Marker2D".global_position,$"../markers/Marker2D4".global_position,$"../markers/Marker2D2".global_position,$"../markers/Marker2D3".global_position,
				].pick_random()
				print("new position: %s"%[agent.target_position])
