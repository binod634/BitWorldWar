@tool
extends Node2D
signal add_avoidance(vertices:PackedVector2Array)


var country_label:PackedScene = preload("res://scenes/components/country_label.tscn")
var country_lands:Dictionary = {}
var lands_count:int = 0
@export var is_playable:bool = false
@export var vertices_data: Dictionary = {}:
	set(value):
		vertices_data = value
		if Engine.is_editor_hint():
			call_deferred("build_everything")
const collision_polygon_minimum_distance_allowded:float = 1
@export var color_value:Color = Color.BLACK
var raw_vector_scale_value:Vector2 = Vector2(3.559,-4.0)
var raw_vector_offset_value:Vector2 = Vector2(640.0,360.0)
@export var country_name:String = ""
@export var country_hashed_name:String = "":
	get():
		return country_name.md5_text()
var capital_name:String = ""
var center_of_country:Vector2 = Vector2.ZERO
var capital_position:Vector2 = Vector2.ZERO
@onready var area2d:Area2D = $Area2D
@onready var specific_nav_region:NavigationRegion2D = $"../../WorldNavigation/SpecificNav"
@onready var navAgent:NavigationAgent2D =  $"../../NavigationAgent2D"
var is_baking:bool = false
var is_baking_completed:bool = false
var navMeshArray:Array = []
var polygons_node:Array[Polygon2D] = []
var collision_polygons_node:Array[CollisionPolygon2D] = []
@onready var conquerWarn:Node2D = $ConquerWarn
var ConquerWarnings:Array[Node2D] = []


func _ready() -> void:
	if not Engine.is_editor_hint():
		build_everything()



func build_everything():
	_decode_all_vertices()
	_add_map_visible_layer_with_collision()
	_put_marking_on_capital()


func _calculate_overall_center():
	var centers_of_each_islands:PackedVector2Array = PackedVector2Array()
	# dict. so 'a' will be 0..n
	for a in country_lands:
		var sumVector:Vector2 = Vector2.ZERO
		for b in country_lands[a]:
			sumVector +=b
		centers_of_each_islands.append(sumVector/len(country_lands[a]))


	# calculate now center of all islands
	var sumsVector:Vector2 = Vector2.ZERO
	for a in centers_of_each_islands:
		sumsVector += a

	# final task. update value
	center_of_country = sumsVector/len(centers_of_each_islands)



func _show_country_label():
	var tmp:Node2D = country_label.instantiate()
	tmp.country_name = country_name
	tmp.position = center_of_country
	area2d.add_child(tmp)
	#tmp.owner = get_tree().edited_scene_root


func _decode_all_vertices():
	if vertices_data.is_empty():
		printerr("No data in vertices")
		return
	is_playable = vertices_data['is_playable']
	var vertices_type = vertices_data['geometry']['type']
	if vertices_type == "Polygon":
		country_lands[0] = _decode_vertices_from_dict(vertices_data['geometry']["coordinates"][0])
		lands_count +=1
	elif vertices_type == "MultiPolygon":
		for coords in vertices_data['geometry']["coordinates"]:
			var tmp:PackedVector2Array = _decode_vertices_from_dict(coords[0])
			if not tmp.is_empty():
				country_lands[lands_count] =  tmp
				lands_count +=1


func _add_map_visible_layer_with_collision():
	for a in range(len(country_lands)):
		_add_full_sided_polygons(country_lands[a])




func _add_full_sided_polygons(tmpvectors:PackedVector2Array):
	var offsets_to_have:PackedVector2Array = [
		Vector2.ZERO,
		Vector2(Game.resolution.x,0),
		Vector2(-Game.resolution.x,0),
	]
	_add_collision_polygon(tmpvectors)
	for offsets in offsets_to_have:
		_add_polygon_with_offset(tmpvectors, offsets)

func _add_collision_polygon(tmpvectors:PackedVector2Array):
	var polygon2d:CollisionPolygon2D = CollisionPolygon2D.new()
	#var clean_vertices:PackedVector2Array = _clean_vectors(tmpvectors)
	check_duplicates(tmpvectors.slice(0,len(tmpvectors ) -1))
	var clean_vertices:PackedVector2Array = tmpvectors.slice(0,len(tmpvectors)-1)
	var tmpname =  "cp_" + str(RandomNumberGenerator.new().randi())
	polygon2d.name = tmpname
	polygon2d.polygon = clean_vertices
	collision_polygons_node.append(polygon2d)
	area2d.add_child(polygon2d)
	polygon2d.owner = owner
	add_avoidance.emit(clean_vertices)



func _clean_vectors(tmpvectors:PackedVector2Array) -> PackedVector2Array:
	var cleaned_vertex:PackedVector2Array = []
	for a in len(tmpvectors):
		if a == 0: continue
		if (tmpvectors[a].distance_to(tmpvectors[a-1]) > collision_polygon_minimum_distance_allowded):
			cleaned_vertex.append(tmpvectors[a])

	# returned cleaned_vertex. tries
	if len(cleaned_vertex) < 3:
		return PackedVector2Array()
	if get_polygon_area(cleaned_vertex) < 5.0:
		return PackedVector2Array()
	return cleaned_vertex
	#return Geometry2D.convex_hull(cleaned_vertex)


func check_duplicates(vertices: PackedVector2Array) -> void:
	for i in range(vertices.size()):
		for j in range(i+1, vertices.size()):
			if vertices[i].distance_to(vertices[j]) < 0.001:
				print("Duplicate or near-duplicate vertices at indices %d and %d: %s %s" % [i, j, vertices[i],vertices[j]])
func get_polygon_area(points: PackedVector2Array) -> float:
	var n = points.size()
	if n < 3:
		return 0.0  # Not a polygon

	var area = 0.0
	for i in range(n):
		var j = (i + 1) % n
		area += points[i].x * points[j].y
		area -= points[j].x * points[i].y
	return abs(area) * 0.5


func _add_polygon_with_offset(tmpvectors:PackedVector2Array,offset:Vector2):
	var polygon2d:Polygon2D = Polygon2D.new()
	polygon2d.color = Color(color_value)
	polygon2d.color = Color.BLACK*0.8 + Color(color_value) * 0.2
	polygon2d.polygon = tmpvectors
	polygon2d.position = offset
	if offset == Vector2.ZERO:
		polygon2d.add_to_group("visual_node_" + country_hashed_name,true)
	polygons_node.append(polygon2d)
	area2d.add_child(polygon2d)
	polygon2d.owner = owner


func _decode_vertices_from_dict(tmp:Array) -> PackedVector2Array:
	var vertices_array:PackedVector2Array = []
	for i in tmp:
		vertices_array.append(_decode_vertices(i[0],i[1]))
	return vertices_array



func _decode_vertices(x:float,y:float) -> Vector2:
	return Vector2(x*raw_vector_scale_value.x+raw_vector_offset_value.x,y*raw_vector_scale_value.y+raw_vector_offset_value.y)



func _make_capital():
	# return if not playable
	if not is_playable:return
	country_name = vertices_data['shapeName']
	capital_name = vertices_data['capital_name']
	var tmpCountryLabel:Node2D = country_label.instantiate()
	tmpCountryLabel.country_name = country_name


func _put_marking_on_capital():
		# return if not playable
	if not is_playable:return
	var capital_location_dict:Array = vertices_data['capital_location']
	capital_name = vertices_data['capital_name']
	capital_position =  _decode_vertices(capital_location_dict[0],capital_location_dict[1])
	area2d.add_child(create_circle_polygon(1.0,capital_position,16))


func create_circle_polygon(radius: float,offset_position:Vector2,segments: int = 64,color: Color = Color.RED) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.z_index = 1
	var points := PackedVector2Array()
	for i in segments:
		var angle = TAU * i / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	poly.polygon = points
	poly.position = offset_position
	poly.color = color
	return poly


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		if event.pressed:
			var mouse_position:Vector2 = get_viewport().get_camera_2d().get_global_mouse_position()
			if (Game._is_country_navigatable(country_hashed_name)):
				Game.send_agent(country_hashed_name,mouse_position)
			else:
				Game.popup_territory_action(country_hashed_name,mouse_position)



func find_navigatoin():
	var mouse_pos_world = get_viewport().get_camera_2d().get_global_mouse_position()
	navAgent.target_position = mouse_pos_world
	navAgent.is_target_reachable()
	print(NavigationServer2D.map_get_path(get_world_2d().get_navigation_map(),Vector2(10,10),mouse_pos_world,true))
	print("to reach: %s"%[mouse_pos_world])


func _is_country_self(hashed_name:String) -> bool:
	return hashed_name == country_hashed_name



func make_new_polygon_from_captured(new_poly: PackedVector2Array):
	var polygon2d:Polygon2D = Polygon2D.new()
	polygon2d.color = Color(color_value)
	polygon2d.color = Color.BLACK*0.8 + Color(color_value) * 0.2
	polygon2d.polygon = new_poly
	polygon2d.position = Vector2.ZERO
	polygon2d.add_to_group("visual_node_" + country_hashed_name,true)
	polygons_node.append(polygon2d)
	area2d.add_child(polygon2d)
	polygon2d.owner = owner

func make_new_collision_polygon_from_captured(new_poly: PackedVector2Array):
	var polygon2d:CollisionPolygon2D = CollisionPolygon2D.new()
	#var clean_vertices:PackedVector2Array = _clean_vectors(tmpvectors)
	check_duplicates(new_poly.slice(0,new_poly.size() -1))
	var clean_vertices:PackedVector2Array = new_poly.slice(0,new_poly.size()-1)
	var tmpname =  "cp_" + str(RandomNumberGenerator.new().randi())
	polygon2d.name = tmpname
	polygon2d.polygon = clean_vertices
	collision_polygons_node.append(polygon2d)
	area2d.add_child(polygon2d)
	polygon2d.owner = owner

func update_existing_collision_polygons(new_polys: Array) -> bool:
	for node in collision_polygons_node:
		var node_polygon:PackedVector2Array = node.polygon
		var result := Geometry2D.clip_polygons(new_polys,node_polygon)
		if  result.is_empty():
			node.polygon = new_polys
			return true
	return false

func update_existing_polygons(new_polys: Array) -> bool:
	var success:bool = false
	for node in polygons_node:
		var node_polygon:PackedVector2Array = node.polygon
		var result := Geometry2D.clip_polygons(new_polys,node_polygon)
		if  result.is_empty():
			node.polygon = new_polys
			success = true
	return success




func generate_circle_polygon(body_position: Vector2, radius_should_be: float) -> PackedVector2Array:
	var circlePoly := PackedVector2Array()
	var segments := 4
	for i in range(segments):
		var angle = TAU * i / segments
		circlePoly.append(body_position + Vector2(cos(angle), sin(angle)) * radius_should_be)
	return circlePoly



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
