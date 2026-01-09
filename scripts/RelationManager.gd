extends Node

# signals
signal build_ready
signal show_country_action_menu
signal show_diplomacy_information_menu

const raw_vector_scale_value:Vector2 = GeoHelper.raw_vector_scale_value
const raw_vector_offset_value:Vector2 = GeoHelper.raw_vector_offset_value

# prefer to have link/name with md5. can also be with coordinate {name:corrdinate} if necessary
var enemy_nations:Array = []
var friendly_countries:Array = []
var territories:Dictionary[String,TerritoryData]  = {}
var countries:Dictionary[String,CountryData] = {}
var my_country_vertices:Array  = []
const file_path:String  = "res://assets/files/simple_countries.json"


func set_country_territories_map(data:Dictionary):
	countries = data

func set_territories(data:Dictionary):
	territories = data
	#PlayerData.select_nation()


func declare_war_on(hashed_name:String):
	assert(countries.has(hashed_name),"No such country data")
	enemy_nations.append(hashed_name)

	#highlight_country(hashed_name,false)
	#enemy_nations.append(hashed_name)
	#make_country_navigatable(hashed_name)
	#print("War declared on %s"%(territories[hashed_name]['name']))
	# update required regions and game.

func is_country_owned(hash_id:String):
	return PlayerData.is_country_mine(hash_id)


func pick_nation(country_id:String):
	# think it should be got from server when asked.
	PlayerData.select_nation(country_id)
	make_country_navigatable(country_id)
	build_ready.emit()

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
	nav_region.travel_cost = 5
	nav_region.navigation_layers = 2
	var new_navigation_mesh:NavigationPolygon = NavigationPolygon.new()
	new_navigation_mesh.agent_radius = 0.5
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


func make_country_navigatable(country_id:String):
	assert(countries.has(country_id),"Can't find country ????")
	for territory_id in countries[country_id].owned_vertices:
		var packed_vector:PackedVector2Array = GeoHelper.decode_vertices_from_dict(territories[territory_id].coordinates)
		add_navigatable_region(packed_vector,territory_id)

func make_friendly_country(hashed_name:String):
	highlight_country(hashed_name,false)
	if hashed_name in enemy_nations:printerr("Cannot be friendly with a war declared country");return
	if hashed_name == PlayerData.country_id: printerr("Cannot be friendly with self");return
	if hashed_name in friendly_countries:printerr("Already friendly");return
	friendly_countries.append(hashed_name)
	add_navigatable_region(territories[hashed_name]['vertices'],hashed_name)

func _is_country_navigatable(hashed_name:String) -> bool:
	var nav_regions:Array = get_tree().get_nodes_in_group("nav_" + hashed_name)
	return nav_regions.size() > 0


func highlight_country(hashed_name:String,positive:bool):
	var nodes:Array = 	get_tree().get_nodes_in_group("visual_node_" + hashed_name)
	for a in nodes:
		a.modulate = Color(1,0,0) if positive else Color(1,1,1)
		a.queue_redraw()



func is_country_enemy(hashed_name:String) -> bool:
	return hashed_name in enemy_nations


func decode_vertices_from_dict(tmp:Array) -> PackedVector2Array:
	var vertices_array:PackedVector2Array = []
	for i in tmp:
		vertices_array.append(decode_vertices(i[0],i[1]))
	return vertices_array

func decode_vertices(x:float,y:float) -> Vector2:
	return Vector2(x*raw_vector_scale_value.x+raw_vector_offset_value.x,y*raw_vector_scale_value.y+raw_vector_offset_value.y)

func create_circle_polygon(radius: float,segments: int = 8,offset_position:Vector2 = Vector2.ZERO,color: Color = Color.RED) -> Polygon2D:
	return GeoHelper.create_circle_polygon(radius,segments,offset_position,color)


func generate_circle_points(radius:float, segments:int,offset_position:Vector2 = Vector2.ZERO) -> PackedVector2Array:
	return GeoHelper.generate_circle_points(radius,segments,offset_position)


func calculate_polygon_area(points: PackedVector2Array) -> float:
	return GeoHelper.calculate_polygon_area(points)


func decode_all_vertices(vertices_data:Dictionary) -> Array[PackedVector2Array]:
	return GeoHelper.decode_all_vertices(vertices_data)

func territory_clicked(country_id:String):
	if PlayerData.is_country_mine(country_id):
		show_country_action_menu.emit()
	else:
		show_diplomacy_information_menu.emit()

func get_territories_from_country_id(id:String) -> Dictionary[String,TerritoryData]:
	assert(countries.has(id),"No country with given hash id")
	var territories_list:PackedStringArray = countries[id].owned_vertices
	assert(territories.has_all(territories_list),"Country doesn't currently hold all data. missmatch data")
	var tmpList:Dictionary[String,TerritoryData] = {}
	for a in territories_list:
		tmpList[a] = territories[a]
	return tmpList
