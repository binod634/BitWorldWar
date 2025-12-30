extends Node

const raw_vector_scale_value:Vector2 = Vector2(3.559,-4.0)
const raw_vector_offset_value:Vector2 = Vector2(640.0,360.0)


# prefer to have link/name with md5. can also be with coordinate {name:corrdinate} if necessary
var enemy_nations:Array = []
var friendly_countries:Array = []
var countries_data:Dictionary  = {}
var my_country_vertices:Array  = []
const file_path:String  = "res://assets/files/simple_countries.json"


func declare_war_on(hashed_name:String):
	highlight_country(hashed_name,false)
	enemy_nations.append(hashed_name)
	make_country_navigatable(hashed_name)
	print("War declared on %s"%(countries_data[hashed_name]['name']))
	# update required regions and game.


func pick_nation():
	# think it should be got from server when asked.
	PlayerData.select_nation({
		'name':"India",
		'hashed_name': "7d31e0da1ab99fe8b08a22118e2f402b",
		'capital_location': Vector2(900,250),
		'capital_name': "New Delhi",
		'lands' : [PackedVector2Array()]
	})

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
			countries_data[hashed_name]['vertices'][0] = World.decode_vertices_from_dict(coordinate_data)
		elif map_type == "MultiPolygon":
			for coords in country['geometry']["coordinates"]:
				var tmp:PackedVector2Array = World.decode_vertices_from_dict(coords[0])
				if not tmp.is_empty():
					countries_data[hashed_name]['vertices'].append(tmp)


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


func make_country_navigatable(hashed_name:String,forced:bool = false):
	if hashed_name == PlayerData.country_id && not forced:
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

func make_friendly_country(hashed_name:String):
	highlight_country(hashed_name,false)
	if hashed_name in enemy_nations:
		printerr("Cannot be friendly with a war declared country")
		return
	if hashed_name == PlayerData.country_id:
		printerr("Cannot be friendly with self")
		return
	if hashed_name in friendly_countries:
		printerr("Already friendly")
		return
	friendly_countries.append(hashed_name)
	add_navigatable_region(countries_data[hashed_name]['vertices'],hashed_name)

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

func get_country_data(hashed_name:String) -> Dictionary:
	return countries_data.get(hashed_name,{})

func create_circle_polygon(radius: float,segments: int = 8,offset_position:Vector2 = Vector2.ZERO,color: Color = Color.RED) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.z_index = 1
	var points := generate_circle_points(radius,segments,offset_position)
	poly.polygon = points
	poly.position = offset_position
	poly.color = color
	return poly

func generate_circle_points(radius:float, segments:int,offset_position:Vector2 = Vector2.ZERO) -> PackedVector2Array:
	var points:PackedVector2Array = PackedVector2Array()
	for i in segments:
		var angle:float = TAU * i/segments
		points.append(Vector2(cos(angle),sin(angle)) * radius + offset_position)
	return points

func calculate_polygon_area(points: PackedVector2Array) -> float:
	var area := 0.0
	var n := points.size()
	if n < 3:
		return 0.0
	for i in range(n):
		var p1 = points[i]
		var p2 = points[(i + 1) % n]
		area += (p1.x * p2.y) - (p2.x * p1.y)
	return abs(area) / 2.0




func decode_all_vertices(vertices_data:Dictionary) -> Array[PackedVector2Array]:
	if vertices_data.is_empty(): printerr("No data in vertices");return []
	var country_lands:Array[PackedVector2Array] = []
	var vertices_type = vertices_data['geometry']['type']
	if vertices_type == "Polygon":
		country_lands.append(decode_vertices_from_dict(vertices_data['geometry']["coordinates"][0]))
	elif vertices_type == "MultiPolygon":
		for coords in vertices_data['geometry']["coordinates"]:
			country_lands.append(decode_vertices_from_dict(coords[0]))
	return country_lands


# func _clean_vectors(tmpvectors:PackedVector2Array) -> PackedVector2Array:
# 	var cleaned_vertex:PackedVector2Array = []
# 	for a in len(tmpvectors):
# 		if a == 0: continue
# 		if (tmpvectors[a].distance_to(tmpvectors[a-1]) > collision_polygon_minimum_distance_allowded):
# 			cleaned_vertex.append(tmpvectors[a])

# 	# returned cleaned_vertex. tries
# 	if len(cleaned_vertex) < 3:
# 		return PackedVector2Array()
# 	if World.calculate_polygon_area(cleaned_vertex) < 5.0:
# 		return PackedVector2Array()
# 	return cleaned_vertex
