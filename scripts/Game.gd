extends  Node


const resolution:Vector2 = Vector2(1280,720) * 2
var country_action_popups:Control


func start_game():
	RelationManager.parse_geolocation_data()
	RelationManager.make_country_navigatable(PlayerData.country_id)

func popup_territory_action(hashed_name:String,location:Vector2):
	if PlayerData.is_country_mine(hashed_name): return
	check_and_remove_exisiting_popups()
	RelationManager.highlight_country(hashed_name,true)
	_make_new_popup(hashed_name,location)



func _make_new_popup(hashed_name:String,location:Vector2):
	var territory_action_menu:Control = preload("res://scenes/tmp/territory_action.tscn").instantiate()
	#get_tree().create_timer(5).timeout.connect(func (): territory_action_menu.queue_free())
	territory_action_menu.global_position = location
	#territory_action_menu.z_index = 1

	territory_action_menu.name = hashed_name
	add_child(territory_action_menu)
	country_action_popups = territory_action_menu

func check_and_remove_exisiting_popups():
	if country_action_popups != null:
		RelationManager.highlight_country(country_action_popups.name,false)
		country_action_popups.name  = "removing..."
		country_action_popups.queue_free()
		country_action_popups = null
