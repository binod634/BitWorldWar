extends Node


# variables
const resolution:Vector2 = Vector2(1280,720)


# prefer to have link/name with md5. can also be with coordinate {name:corrdinate} if necessary
var enemy_nations:Array = []
var friendly_countries:Array = []
var selected_country:Dictionary = {}
var countries_data:Dictionary  = {}
var agents:Array = []
var my_country_vertices:Array  = []
var country_action_popups:Control  # to track existing popup menus

# objects
# file to build nations
const file_path:String  = "res://assets/files/simple_countries.json"




func start_game():
	pick_nation()
	parse_geolocation_data()
	make_country_navigatable(selected_country['hashed_name'],true)


func pick_nation():
	# think it should be got from server when asked.
	selected_country = {
		'name':"India",
		'hashed_name': "7d31e0da1ab99fe8b08a22118e2f402b",
		'capital_location': Vector2(900,250),
		'capital_name': "New Delhi",
		'lands' : [PackedVector2Array()]
	}

func parse_geolocation_data():
	var countries_list:Array = load_regions_file()
	for country in countries_list:
		var country_name:String = country['shapeName']
		var hashed_name:String = country_name.md5_text()
		var map_type:String = country['geometry']['type']
		countries_data[hashed_name] = {
			'is_playable': country['is_playable'],
			'name': country_name,
			'vertices': [[]],
		}
		if map_type == "Polygon":
			var coordinate_data:Array = country['geometry']["coordinates"][0]
			countries_data[hashed_name]['vertices'][0] = VerticesHelper.decode_vertices_from_dict(coordinate_data)
		elif map_type == "MultiPolygon":
			for coords in country['geometry']["coordinates"]:
				var tmp:PackedVector2Array = VerticesHelper.decode_vertices_from_dict(coords[0])
				if not tmp.is_empty():
					countries_data[hashed_name]['vertices'].append(tmp)



func convert_geolocation_to_packedvector2array():
	pass


func load_regions_file():
	var file:FileAccess = FileAccess.open(file_path,FileAccess.READ)
	if file == null:
		print("errored")
		return
	return JSON.parse_string(file.get_as_text())



func add_navigatable_region(vertices:PackedVector2Array,hashed_name:String):
	var nav_region = NavigationRegion2D.new()
	nav_region.add_to_group("nav_" + hashed_name)
	nav_region.name = generate_navigation_region_name(hashed_name)
	nav_region.enter_cost = 100
	nav_region.travel_cost = 2
	nav_region.navigation_layers = 2
	var new_navigation_mesh:NavigationPolygon = NavigationPolygon.new()
	new_navigation_mesh.agent_radius = 1
	new_navigation_mesh.cell_size = 10
	new_navigation_mesh.add_outline(vertices)
	# NavigationServer2D.map_changed.connect(func (_di): print("not map changed"))
	NavigationServer2D.bake_from_source_geometry_data(new_navigation_mesh, NavigationMeshSourceGeometryData2D.new());
	nav_region.navigation_polygon = new_navigation_mesh
	get_navigation_parent_node().add_child(nav_region)


func generate_navigation_region_name(hashed_name:String):
	return hashed_name + str(RandomNumberGenerator.new().randi())

func get_navigation_parent_node():
	return get_tree().get_first_node_in_group("NavigatableLandRegion")


func make_country_navigatable(hashed_name:String,forced:bool = false):
	if hashed_name == selected_country['hashed_name'] && not forced:
		printerr("This is selected country. already navigatable")
		return
	var vertices_data:Array = countries_data[hashed_name]['vertices']

	if vertices_data.is_empty():
		printerr("No data found in country data...")
		return

	if (len(vertices_data) == 1):
		add_navigatable_region(PackedVector2Array(vertices_data[0]),hashed_name)
	else:
		for i in vertices_data:
			add_navigatable_region(PackedVector2Array(i),hashed_name)


func declare_war_on(hashed_name:String):
	_highlight_country(hashed_name,false)
	enemy_nations.append(hashed_name)
	make_country_navigatable(hashed_name)
	print("War declared on %s"%(countries_data[hashed_name]['name']))
	# update required regions and game.


func make_friendly_country(hashed_name:String):
	_highlight_country(hashed_name,false)
	if hashed_name in enemy_nations:
		printerr("Cannot be friendly with a war declared country")
		return
	if hashed_name == selected_country['hashed_name']:
		printerr("Cannot be friendly with self")
		return
	if hashed_name in friendly_countries:
		printerr("Already friendly")
		return
	friendly_countries.append(hashed_name)
	add_navigatable_region(countries_data[hashed_name]['vertices'],hashed_name)

func send_agent(hashed_name:String,target_position:Vector2):
	if agents.size() >= 10:
		printerr("Max agents deployed")
		return
	_add_agent(hashed_name,target_position)

func _add_agent(hashed_name:String,target_position:Vector2):
	var player_agent:CharacterBody2D = preload("res://scenes/tmp/player_agent.tscn").instantiate()
	player_agent.target_position = target_position
	player_agent.position = selected_country['capital_location']
	player_agent.host_country = hashed_name
	player_agent.name = "agent_" + str(agents.size())
	get_tree().get_first_node_in_group("AgentsParent").add_child(player_agent)
	agents.append(player_agent)
	# var agent:NavigationAgent2D = NavigationAgent2D.new()
	# agent.radius = 5
	# agent.target_desired_distance = 10
	# agent.path_max_distance = 10000
	# agent.name = "agent_" + str(agents.size())
	# agent.add_to_group("agent_" + hashed_name)
	# agent.position = selected_country['capital_location']
	# agent.target_position = target_position
	# get_tree().get_first_node_in_group("AgentsParent").add_child(agent)
# 	# agents.append(agent)

# func _add_agent_old(hashed_name:String,target_position:Vector2):
# 	var agent:NavigationAgent2D = NavigationAgent2D.new()
# 	agent.radius = 5
# 	agent.target_desired_distance = 10
# 	agent.path_max_distance = 10000
# 	agent.name = "agent_" + str(agents.size())
# 	agent.add_to_group("agent_" + hashed_name)
# 	agent.position = selected_country['capital_location']
# 	agent.target_position = target_position
# 	get_tree().get_first_node_in_group("AgentsParent").add_child(agent)
# 	agents.append(agent)


func _is_country_navigatable(hashed_name:String) -> bool:
	var nav_regions:Array = get_tree().get_nodes_in_group("nav_" + hashed_name)
	return nav_regions.size() > 0


func popup_territory_action(hashed_name:String,location:Vector2):
	check_and_remove_exisiting_popups()
	_highlight_country(hashed_name,true)
	make_new_popup(hashed_name,location)

func make_new_popup(hashed_name:String,location:Vector2):
	print("making popup name %s"%[hashed_name])
	var territory_action_menu:Control = preload("res://scenes/tmp/territory_action.tscn").instantiate()
	#get_tree().create_timer(5).timeout.connect(func (): territory_action_menu.queue_free())
	territory_action_menu.global_position = location
	territory_action_menu.z_index = 1

	territory_action_menu.name = hashed_name
	add_child(territory_action_menu)
	country_action_popups = territory_action_menu

func check_and_remove_exisiting_popups():
	if country_action_popups != null:
		_highlight_country(country_action_popups.name,false)
		country_action_popups.name  = "removing..."
		country_action_popups.queue_free()
		country_action_popups = null

func _highlight_country(hashed_name:String,positive:bool):
	var nodes:Array = 	get_tree().get_nodes_in_group("visual_node_" + hashed_name)
	for a in nodes:
		a.modulate = Color(1,0,0) if positive else Color(1,1,1)
		a.queue_redraw()


func remove_agent(agent:CharacterBody2D):
	if not is_instance_valid(agent):
		printerr("Agent is not valid anymore")
		return
	agents.erase(agent)
	agent.queue_free()



func is_country_enemy(hashed_name:String) -> bool:
	return hashed_name in enemy_nations

func apply_damage_to_country(hashed_name:String,area_taken:float):
	print("Applying %f damage to country %s"%[area_taken,countries_data[hashed_name]['name']])
