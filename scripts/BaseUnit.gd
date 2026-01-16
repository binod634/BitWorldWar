extends CharacterBody2D
class_name BaseUnit

@export var nav_agent: NavigationAgent2D
@export var character_texture: Sprite2D
@export var hover_sound:AudioStreamPlayer2D
@export var selection_sound:AudioStreamPlayer2D
@onready var character_default_scale:Vector2 = character_texture.scale
@export var selection_area:Area2D
@export_group("Identity")
@export var country_id: String
@export var unit_type: String
@export_group("Stats")
@export var speed: float = 150.0
@export var max_health: float = 100.0
@onready var current_health: float = max_health
var target_pos: Vector2 = Vector2.ZERO:
	set(value):
		target_pos = value
		if value != Vector2.ZERO:
			#print("updating paths...")
			nav_agent.target_position = value
			nav_agent.get_next_path_position()
		else:
			assert(false)
var next_path:Vector2 = Vector2.ZERO:
	set(value):
		next_path = value
		if value != Vector2.ZERO:
			character_texture.rotation = global_position.direction_to(value).angle()

var has_path:bool = false:
	set(value):
		has_path = value
var timer:Timer
var is_selected: bool = false:
	set(val):
		is_selected = val
		_update_visuals()
		#if is_inside_tree():
		_register_selection(val)
		setup_perioudic_sound()
		if val: play_selection_sound()


func _ready() -> void:
	assert(character_texture,"No character texture set!!!")
	assert(not unit_type.is_empty(),"no name ?")
	assert(country_id,"no country id ?")
	assert(selection_area,"No area2d for selection specified!")
	#assert(selection_sound,"No unit clicked sound")
	assert(hover_sound,"No unit hover sound")
	assert(nav_agent,"Really ? no navagent")
	set_visiblity()
	register_mouse_inputs()
	register_path_update()

func register_path_update():
	nav_agent.path_changed.connect(_check_path)
	nav_agent.navigation_finished.connect(
		func ():
			has_path = false
	)

func _check_path():
	#print("checking for path...")
	if nav_agent.is_target_reached(): return
	has_path = true
	next_path = nav_agent.get_next_path_position()

func _physics_process(delta):
	if not has_path: return
	var got_path:Vector2 = global_position.direction_to(next_path) * speed
	velocity = got_path if check_overshoot(delta) else Vector2.ZERO
	move_and_slide()


func check_overshoot(deltaTime:float):
	if (speed * deltaTime)/abs(global_position.distance_to(next_path)) >= 1:
		global_position = next_path
		get_next_path()
		return false
	return true

func get_next_path():
	if  nav_agent.is_navigation_finished():
		has_path = false
	else:
		next_path = nav_agent.get_next_path_position()


func _update_visuals():
	character_texture.scale = character_default_scale * 1.2 if is_selected else character_default_scale
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

func register_mouse_inputs():
	selection_area.input_event.connect(clicked_baby)
	selection_area.mouse_entered.connect(_mouse_entered)
	selection_area.mouse_exited.connect(_mouse_exitted)


func _mouse_entered():
	play_hovering_sound()

func play_hovering_sound():
	hover_sound.pitch_scale = get_random_pitch_scale()
	hover_sound.play()

func _mouse_exitted():
	pass

func play_selection_sound():
	play_hovering_sound()

func setup_perioudic_sound():
	if not  timer:
		timer = Timer.new()
		timer.wait_time = 10
		timer.autostart = true
		timer.timeout.connect(_play_perioudic_sound)
		add_child(timer)

func _play_perioudic_sound():
	if is_selected:
		timer.wait_time = 10 + randf() * 10
		play_selection_sound()

func _register_selection(selected:bool):
	if selected: ArmyManager.add_army_to_selection(self)
	else: ArmyManager.remove_army_from_selection(self)

func clicked_baby(_viewport: Node, event: InputEvent, _shape_idx: int):
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		if event.is_pressed():
			is_selected = !is_selected

func get_random_pitch_scale() -> float:
	return 1 + randf_range(-1,1) * 0.1
