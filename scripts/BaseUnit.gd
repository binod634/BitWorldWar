extends CharacterBody2D
class_name BaseUnit

@export var character_texture: Sprite2D
@onready var character_default_scale:Vector2 = character_texture.scale
@export var selection_area:Area2D

@export_group("Identity")
@export var country_id: String
@export var unit_type: String

@export_group("Stats")
@export var max_health: float = 100.0
@onready var current_health: float = max_health

var is_selected: bool = false:
	set(val):
		is_selected = val
		_update_visuals()


func _ready() -> void:
	assert(character_texture,"No character texture set!!!")
	assert(not unit_type.is_empty(),"no name ?")
	assert(country_id,"no country id ?")
	assert(selection_area,"No area2d for selection specified!")
	set_visiblity()
	register_selection()

func _update_visuals():
	character_texture.scale = character_default_scale * 1.5 if is_selected else character_default_scale
	character_texture.self_modulate = Color.WHITE * 1.5 if is_selected else Color.WHITE

func take_damage(amount: float):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	queue_free()

func set_visiblity():
	if country_id != "debug":
		visible = PlayerData.is_country_mine(country_id)

func register_selection():
	selection_area.input_event.connect(clicked_baby)


func clicked_baby(_viewport: Node, event: InputEvent, _shape_idx: int):
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		if event.is_pressed():
			is_selected = !is_selected

func get_random_pitch_scale() -> float:
	return 1 + randf_range(-1,1) * 0.1
