@tool
extends  Node2D


@export var owned_territory_id:Array = []
@export var owned_country:String
@export var is_playable_country:bool = false
@export var default_owned_polygons_id:Array = []
@export var owned_territory_data:Dictionary = {}
var visual_nodes:Array[Polygon2D] = []
var collision_nodes:Array[CollisionPolygon2D] = []
#var duplicated_nodes_right:Array[Polygon2D] = []
#var duplicated_nodes_left:Array[Polygon2D] = []
var centers_of_polygons:PackedVector2Array = PackedVector2Array()

#onready
@onready var CollisionArea:Area2D = $CollisionArea
@onready var Visuals:Node2D = $Visuals
@onready var Armys:Node2D = $Army

# scenes
var playerAgent:PackedScene = preload("res://scenes/tmp/player_agent.tscn")



func _ready() -> void:
	if not Engine.is_editor_hint():
		World.setup_completed.connect(build_runtime)


func build_runtime():
	build_territory(false)
	deploy_army()

func deploy_army():
	for i in centers_of_polygons:
		var tmp:CharacterBody2D = playerAgent.instantiate()
		tmp.global_position = i
		Armys.add_child(tmp)


func _draw() -> void:
	#if not is_playable_country: return
	#for i in centers_of_polygons:
		#draw_circle(i,0.5,Color.RED)
	for i in visual_nodes:
		draw_polyline(i.polygon,Color.WHITE)



func build_territory(is_editor_build:bool = true):
	for polygons_id in default_owned_polygons_id:
		if owned_territory_data.has(polygons_id):
			var country_info:Dictionary = owned_territory_data[polygons_id]
			var color:Color = country_info.get("color", Color.WHITE)
			var polygon_vertices:Array = country_info.get("polygon_vertices", [])

			# there should be 1 array
			var packed_vertices:PackedVector2Array = PackedVector2Array()
			assert(polygon_vertices.size() == 1,"Polygon size is not 1")
			for i in polygon_vertices[0]:
				packed_vertices.append(GeoHelper.decode_vertices(i[0],i[1]))
			#var decomposed = Geometry2D.decompose_polygon_in_convex(polygon_vertices[0])
			#if decomposed.is_empty():
				#print("--- CONVEX DECOMPOSITION FAILED ---")
				#print("Territory Name/ID: ", polygons_id)
				#print("Vertex Count: ", polygon_vertices.size())
				#print("Vertices: ", polygon_vertices)
			if GeoHelper.calculate_polygon_area(packed_vertices) > 5:
				centers_of_polygons.append(center_point_in_polygon(packed_vertices))
			else:
				print("got area less %s"%[GeoHelper.calculate_polygon_area(packed_vertices)])
			build_collision_node(packed_vertices,polygons_id,is_editor_build)
			build_polygon_node(packed_vertices,polygons_id,is_editor_build,color)
	queue_redraw()

func build_polygon_node(polygon:PackedVector2Array,node_name:String,is_editor_build:bool,node_color:Color):
	var polygonNode:Polygon2D = Polygon2D.new()
	polygonNode.add_to_group("navigation_avoid",true)
	polygonNode.polygon = polygon
	polygonNode.name = node_name
	polygonNode.color = node_color
	visual_nodes.append(polygonNode)
	Visuals.add_child(polygonNode)
	if is_editor_build: polygonNode.owner = get_tree().edited_scene_root


func build_collision_node(polygon:PackedVector2Array,node_name:String,is_editor_build:bool):
	var collisionNode:CollisionPolygon2D = CollisionPolygon2D.new()

	collisionNode.polygon = polygon
	collisionNode.name = node_name
	collision_nodes.append(collisionNode)
	CollisionArea.add_child(collisionNode)
	if is_editor_build: collisionNode.owner = get_tree().edited_scene_root

func center_point_in_polygon(polygon:PackedVector2Array) -> Vector2:
	# Calculate centroid
	var center:Vector2 = Vector2.ZERO
	for point in polygon:
		center += point
	center /= polygon.size()
	# Check if centroid is inside polygon
	if Geometry2D.is_point_in_polygon(center, polygon):
		return center
	# If not, try to find a reliable fallback inside the polygon
	var fallback1:Vector2 = polygon[0]
	for a in range(1, len(polygon)):
		var testCenter = (fallback1 * a + polygon[a]) / (a + 1)
		if not Geometry2D.is_point_in_polygon(testCenter, polygon):
			# If fallback1 steps outside, revert to previous value and break
			break
		else:
			fallback1 = testCenter
	if Geometry2D.is_point_in_polygon(fallback1, polygon):
		return fallback1
	if polygon.size() >= 3:
		var fallback2:Vector2 = (polygon[0] + polygon[1] + polygon[2]) / 3.0
		if Geometry2D.is_point_in_polygon(fallback2, polygon):
			return fallback2
	# As a last resort, return the first vertex
	return polygon[0]
