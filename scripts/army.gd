extends CharacterBody2D


@onready var character:Sprite2D = $Army
@onready var navAgent:NavigationAgent2D = $NavigationAgent2D
@export var owned_country:String
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
@onready var default_scale_value:Vector2 =  $Army.scale

func _ready() -> void:
	name = "army_" + str(randi())
	visible = World.is_country_owned(owned_country)

func _physics_process(_delta: float) -> void:
	if navAgent.is_navigation_finished(): return
	var got_path:Vector2 = global_position.direction_to(navAgent.get_next_path_position()).normalized() * 100
	velocity = got_path
	move_and_slide()



func update_player_global(value:bool):
	if value:
		ArmyManager.add_army_to_selection(self)
	else:
		ArmyManager.remove_army_from_selection(self)

func operate_character_scale(polarity:bool):
	character.scale = default_scale_value if not polarity else default_scale_value * 1.5

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
