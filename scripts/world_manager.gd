extends Node

# enums
enum ActionType {
	NONE,
	BUILD,
}

# signals
signal setup_completed
signal overlay_visiblity_changed(visible:bool)
signal show_diplomacy_information_menu(countryData:CountryModel)
signal relation_changed(id:String,relation:DiplomacyData.relation)
signal highlight_territory_for_construction_mode(territory_id:String)

const raw_vector_scale_value:Vector2 = GeoHelper.raw_vector_scale_value
const raw_vector_offset_value:Vector2 = GeoHelper.raw_vector_offset_value

var enemy_nations:Array = []
var friendly_countries:Array = []
var territories:Dictionary[String,TerritoryModel]  = {}
var countries:Dictionary[String,CountryModel] = {}
var navigatable_territories:PackedStringArray = []
var selected_territory:String
var current_action_mode:ActionType = ActionType.NONE
var current_action_building:BuildingData
#const file_path:String  = "res://assets/files/simple_countries.json"


func set_country_territories_map(data:Dictionary):
	countries = data

func set_territories(data:Dictionary):
	territories = data
	#PlayerData.select_nation()


func declare_war_on(hashed_name:String):
	assert(countries.has(hashed_name),"No such country data")
	enemy_nations.append(hashed_name)
	# make full country navigatabe.
	make_country_navigatable(hashed_name)
	relation_changed.emit(hashed_name,DiplomacyData.relation.war)

func is_country_owned(hash_id:String):
	return PlayerData.is_country_mine(hash_id)


func pick_nation(country_id:String):
	assert(countries.has(country_id),"country id not in countries data...")
	if not countries.has(country_id): return
	PlayerData.select_nation(country_id)
	make_country_navigatable(country_id)
	setup_completed.emit()




func add_navigatable_region(vertices:PackedVector2Array,territory_id:String,isOwnedTerritory:bool = false):
	var nav_region = NavigationRegion2D.new()
	#nav_region.add_to_group("nav_" + territory_id)
	nav_region.name = territory_id
	#nav_region.name = generate_navigation_region_name(territory_id)
	nav_region.enter_cost = 100 if not isOwnedTerritory else 50
	nav_region.travel_cost = 5 if not isOwnedTerritory else 1
	nav_region.navigation_layers = 2
	var new_navigation_mesh:NavigationPolygon = NavigationPolygon.new()
	new_navigation_mesh.agent_radius = 0.5
	new_navigation_mesh.cell_size = 10
	new_navigation_mesh.add_outline(vertices)
	NavigationServer2D.bake_from_source_geometry_data(new_navigation_mesh, NavigationMeshSourceGeometryData2D.new());
	nav_region.navigation_polygon = new_navigation_mesh
	get_navigation_parent_node().add_child(nav_region)
	#print("add navigation success: %s"%[hashed_name])

#func simplify_and_shrink(points: PackedVector2Array) -> PackedVector2Array:
#	# 1. Offset (shrink) the polygon inward by 0.1 units
#	# JOIN_MITER (0) keeps corners sharp; -0.1 shrinks it.
#	var offset_polygons = Geometry2D.offset_polygon(points, -0.5, Geometry2D.JOIN_MITER)
#
#	if offset_polygons.size() > 0:
#		return offset_polygons[0] # Returns the newly shrunk polygon
#	return points


func get_navigation_parent_node():
	return get_tree().get_first_node_in_group("NavigatableLandRegion")


func make_country_navigatable(country_id:String):
	assert(countries.has(country_id),"Can't find country ????")
	var isOwned:bool = PlayerData.is_country_mine(country_id)
	for territory_id in countries[country_id].territories_id:
		if not navigatable_territories.has(territory_id):
			add_navigatable_region(territories[territory_id].coordinates,territory_id,isOwned)
			navigatable_territories.append(territory_id)
		else:
			assert(false)

func make_friendly_country(hashed_name:String):
	assert(hashed_name not in enemy_nations,"Can't be friendly with enemy nations...")
	assert(hashed_name not in friendly_countries,"Relation is already friendly. why double ?")
	if not OS.is_debug_build() && (enemy_nations.has(hashed_name) || friendly_countries.has(hashed_name)):
		return
	make_country_navigatable(hashed_name)
	highlight_country(hashed_name,false)
	friendly_countries.append(hashed_name)

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

func territory_clicked(country_id:String,territory_id:String):
	assert(countries.has(country_id))
	if PlayerData.is_country_mine(country_id):
		assert(territories.has(territory_id))
		print("[*] data got of mine. country_id: %s and territory_id: %s."%[country_id,territory_id])
		highlight_territory_for_construction_mode.emit(territory_id,selected_territory)
		selected_territory = territory_id

	elif (current_action_mode == ActionType.NONE):
		show_diplomacy_information_menu.emit(countries[country_id])

func construct_building(type:BuildingData):
	current_action_mode = ActionType.BUILD
	overlay_visiblity_changed.emit(false)
	current_action_building = type


func check_building_count(type:Game.BuildingType) -> int:
	assert(Game.buildings.has(type),"No such building type")
	var count:int = 0
	for  a in countries[PlayerData.selected_nation_id].territories_id:
		for b in territories[a].buildings:
			if b.building_type == Game.buildings[type]:
				count += 1
	return count

func check_production_for_active_building():
	var time_passed:float = Game.time_interval * Game.time_scale
	for key in territories:
		var buildings:Array[BuildingModel] = territories[key].buildings

		# so the building is active and in production queue
		for building in buildings:
			if not building.is_active: continue
			if building.remaining_time > time_passed:
				building.remaining_time -= time_passed
			else:
				if building.current_production_queue > 0:
					building.current_production_queue -= 1
					building.remaining_time = building.production_time - time_passed
				else:
					building.is_active = false
					building.remaining_time = 0



func ask_shortest_territory_for_nation_from_point(point:Vector2,country_id:String) -> Vector2:
	assert(countries.has(country_id),"No such country data")
	assert(enemy_nations.has(country_id),"No territories data loaded...")
	assert(territories.size() > 0,"No territories data loaded...")
	assert(countries[country_id].territories_id.size() > 0,"countries has no territories...")
	var shortest_distance:float = INF
	var current_territory:TerritoryModel = null
	for terrritory_id in countries[country_id].territories_id:
		assert(territories.has(terrritory_id),"Territory id not found in territories data...")
		var territory:TerritoryModel = territories[terrritory_id]
		if ( point.distance_to(territory.center) < shortest_distance):
			shortest_distance = point.distance_to(territory.center)
			current_territory = territory
	return current_territory.center

func get_territory_for_id(id:String) -> TerritoryModel:
	assert(territories.has(id),"No such territory data...")
	return territories[id]
