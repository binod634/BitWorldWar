extends Node


# variables
const resolution:Vector2 = Vector2(1280,720)


# prefer to have link/name with md5. can also be with coordinate {name:corrdinate} if necessary
var war_declared_with:Array = []
var friendly_countries:Array = []
var selected_country:Dictionary = {}
var countries_data:Dictionary  = {}


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
	nav_region.enter_cost = 5000
	nav_region.travel_cost = 5
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
	war_declared_with.append(hashed_name)
	add_navigatable_region(countries_data[hashed_name]['vertices'],hashed_name)
	# update required regions and game.


func make_friendly_country(hashed_name:String):
	if hashed_name in war_declared_with:
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
