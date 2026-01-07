@tool
extends  Node2D


@export var owned_territory_id:Array = []
@export var owned_country:String
@export var is_playable_country:bool = false
@export var default_owned_polygons_id:Array = []
@export var territory_data:Dictionary = {}
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
var playerAgent:PackedScene = preload("res://scenes/objects/army.tscn")


func _ready() -> void:
	if not Engine.is_editor_hint():
		World.setup_completed.connect(build_runtime)


func build_runtime():
	build_territory(false)
	make_dollar_effect_if_owned()
	deploy_army()

func make_dollar_effect_if_owned():
	if not World.is_country_owned(owned_country): return
	make_particles_effects()

func make_particles_effects():
	pass

func deploy_army():
	for i in centers_of_polygons:
		var tmp:CharacterBody2D = playerAgent.instantiate()
		tmp.global_position = i
		tmp.owned_country = owned_country
		Armys.add_child(tmp)


func _draw() -> void:
	# show line in every polygon
	for i in visual_nodes:
		draw_polyline(i.polygon,Color.WHITE)



func build_territory(is_editor_build:bool = true):
	for polygons_id in default_owned_polygons_id:
		if territory_data.has(polygons_id):
			#var color:Color = GeoHelper.string_to_color(owned_country) * 0.95 + Color(randf(),randf(),randf()) * 0.05
			var owned_color:Color = Colors.ColorsValue[Colors.ColorName.LightBlue]
			var neutral_color:Color = Colors.ColorsValue[Colors.ColorName.Green]
			var color:Color = owned_color if not is_editor_build &&  PlayerData.is_country_mine(owned_country) else (neutral_color * 0.8  + GeoHelper.string_to_color(owned_country) * 0.2)
			# there should be 1 array
			var packed_vertices:PackedVector2Array = PackedVector2Array()
			for i in territory_data[polygons_id][GeoHelper.TerritoryData.coordinates]:
				packed_vertices.append(GeoHelper.decode_vertices(i[0],i[1]))
			if GeoHelper.calculate_polygon_area(packed_vertices) > 5:
				var center:Array = territory_data[polygons_id][GeoHelper.TerritoryData.center]
				if center.is_empty():
					centers_of_polygons.append(center_point_in_polygon(packed_vertices))
				else:
					centers_of_polygons.append(GeoHelper.decode_vertices(center[0],center[1]))
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


func _on_collision_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_MASK_LEFT && event.is_pressed()):
		# Game.popup_territory_action(owned_country,get_global_mouse_position())
		pass
