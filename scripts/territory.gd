@tool
extends Node2D

# signals
signal add_avoidance(vertices:PackedVector2Array)

# const
const collision_polygon_minimum_distance_allowded:float = 1


# variables
var country_polygons:Array = []
var capital_name:String = ""
var center_of_country:Vector2 = Vector2.ZERO
var capital_position:Vector2 = Vector2.ZERO
var polygons_node:Array[Polygon2D] = []
var collision_polygons_node:Array[CollisionPolygon2D] = []
var ConquerWarnings:Array[Node2D] = []

#exports
@export var color_value:Color = Color.BLACK
@export var country_name:String = ""
@export var country_id:String = "":
	get():
		return country_name.md5_text()
@export var is_playable:bool = false
@export var vertices_data: Dictionary = {}:
	set(value):
		vertices_data = value
		if Engine.is_editor_hint():
			call_deferred("build_editor")

# onready
@onready var area2d:Area2D = $Area2D

func _ready() -> void:
	if not Engine.is_editor_hint():
		build_everything()

func build_editor():
	_decode_map_editor()
	_add_map_visible_layer_with_collision()
	_put_marking_on_capital()



func build_everything():
	_check_playable()
	_decode_map()
	_add_map_visible_layer_with_collision()
	_put_marking_on_capital()

func _decode_map_editor():
	country_polygons =  GeoHelper.decode_all_vertices(vertices_data)


func _check_playable():
	is_playable = vertices_data['is_playable']

func _add_map_visible_layer_with_collision():
	for a in range(len(country_polygons)):
		_add_full_sided_polygons(country_polygons[a])

func _decode_map():
	country_polygons =  World.decode_all_vertices(vertices_data)


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



func check_duplicates(vertices: PackedVector2Array) -> void:
	for i in range(vertices.size()):
		for j in range(i+1, vertices.size()):
			if vertices[i].distance_to(vertices[j]) < 0.001:
				print("Duplicate or near-duplicate vertices at indices %d and %d: %s %s" % [i, j, vertices[i],vertices[j]])


func _add_polygon_with_offset(tmpvectors:PackedVector2Array,offset:Vector2):
	var polygon2d:Polygon2D = Polygon2D.new()
	polygon2d.color = Color(color_value)
	polygon2d.color = Color.BLACK*0.8 + Color(color_value) * 0.2
	polygon2d.polygon = tmpvectors
	polygon2d.position = offset
	if offset == Vector2.ZERO:
		polygon2d.add_to_group("navigation_avoid",true)
		polygon2d.add_to_group("visual_node_" + country_id,true)
	polygons_node.append(polygon2d)
	area2d.add_child(polygon2d)
	polygon2d.owner = owner


func _decode_vertices_from_dict(tmp:Array) -> PackedVector2Array:
	var vertices_array:PackedVector2Array = []
	for i in tmp:
		vertices_array.append(World.decode_vertices(i[0],i[1]))
	return vertices_array


func _put_marking_on_capital():
	if not is_playable:return
	var capital_location_dict:Array = vertices_data['capital_location']
	capital_name = vertices_data['capital_name']
	capital_position =  World.decode_vertices(capital_location_dict[0],capital_location_dict[1])
	var tmp:Polygon2D = World.create_circle_polygon(1.0,16,capital_position)
	area2d.add_child(tmp)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		if event.pressed:
			if PlayerData.is_country_mine(country_id): return
			var mouse_position:Vector2 = get_viewport().get_camera_2d().get_global_mouse_position()
			if (World._is_country_navigatable(country_id)):
				ArmyManager.send_agent(country_id,mouse_position)
			else:
				Game.popup_territory_action(country_id,mouse_position)



func _is_country_self(hashed_name:String) -> bool:
	return hashed_name == country_id



func make_new_polygon_from_captured(new_poly: PackedVector2Array):
	var polygon2d:Polygon2D = Polygon2D.new()
	polygon2d.color = Color(color_value)
	polygon2d.color = Color.BLACK*0.8 + Color(color_value) * 0.2
	polygon2d.polygon = new_poly
	polygon2d.position = Vector2.ZERO
	polygon2d.add_to_group("visual_node_" + country_id,true)
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



func _on_area_2d_body_entered(body: Node2D) -> void:
	# not any army
	if body is CharacterBody2D and body.has_method("entered_territory"):
		body.entered_territory(country_id,being_capturing)


func being_capturing(radius:float,location:Vector2,_hashed_name:String,):
	var polygon_asked:PackedVector2Array = World.generate_circle_points(radius,8,location)
	for country_polygon in country_polygons:
		var intersection:Array[PackedVector2Array] = Geometry2D.intersect_polygons(country_polygon,polygon_asked)
		if intersection.is_empty():
			continue # no intersection. not this land
		else:
			var warn_poly_instance:Node2D = preload("res://scenes/tmp/warn_poly.tscn").instantiate()
			warn_poly_instance.polygons = intersection
			add_child(warn_poly_instance)
