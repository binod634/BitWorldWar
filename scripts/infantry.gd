extends CharacterBody2D


@onready var character:Node2D = $Character
@onready var default_scale_value:Vector2 =  $Character.scale
@onready var navAgent:NavigationAgent2D = $NavigationAgent2D
@onready var infantry_sound:AudioStreamPlayer2D = $InfantrySound
@export var country_id:String
var has_path:bool = false:
	set(value):
		has_path = value
		set_physics_process(value)
var next_path:Vector2 = Vector2.ZERO
const  SPEED:float = 100
var target_position:Vector2 = Vector2.ZERO:
	set(value):
		target_position = value
		navAgent.target_position = value

var is_character_glowing:bool = false:
	set(value):
		if is_character_selected && not value: return
		is_character_glowing = value
		operate_character_scale(value)
var is_character_selected:bool = false:
	set(value):
		is_character_selected = value
		change_character_glow(value)
		update_player_global(value)

func _ready() -> void:
	name = "infantry_" + str(randi())
	set_physics_process(has_path)
	navAgent.navigation_finished.connect(_navigation_completed)
	navAgent.path_changed.connect(_check_and_update_if_reachable)
	visible = RelationManager.is_country_owned(country_id)

func _physics_process(delta: float) -> void:
	if not has_path:
		assert(false,"this shouldn't have happened")
		return
	var got_path:Vector2 = global_position.direction_to(next_path) * SPEED
	velocity = got_path if check_overshoot(delta) else Vector2.ZERO
	move_and_slide()

func check_overshoot(deltaTime:float):
	if (SPEED * deltaTime)/abs(global_position.distance_to(next_path)) >= 1:
		global_position = next_path
		get_next_path()
		return false
	return true


func get_next_path():
	if not  navAgent.is_navigation_finished():
		next_path = navAgent.get_next_path_position()
	else:
		has_path = false


func _navigation_completed():
	has_path = false


func _check_and_update_if_reachable():
	print("got navigatino upate")
	if navAgent.is_target_reachable() &&  not navAgent.is_target_reached():
		has_path = true
		set_physics_process(true)
		next_path = navAgent.get_next_path_position()
		character.rotation = global_position.direction_to(next_path).angle()

func update_player_global(value:bool):
	if value:
		ArmyManager.add_army_to_selection(self)
	else:
		ArmyManager.remove_army_from_selection(self)

func operate_character_scale(polarity:bool):
	character.scale = default_scale_value if not polarity else default_scale_value * 1.5
	if polarity: play_infantry_sound()

func change_character_glow(polarity:bool):
	character.self_modulate =  Color.WHITE * 1.3 if polarity else Color.WHITE
#
func _on_area_2d_mouse_shape_entered(_shape_idx: int) -> void:
	is_character_glowing = true


func _on_area_2d_mouse_shape_exited(_shape_idx: int) -> void:
	is_character_glowing = false


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed()):
		is_character_selected = !is_character_selected

func reset_selection():
	is_character_selected = false
	is_character_glowing = false


func play_infantry_sound():
	infantry_sound.pitch_scale = 1 + randf_range(-1,1) * 0.1
	infantry_sound.play()
