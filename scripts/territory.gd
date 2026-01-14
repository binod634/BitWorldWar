extends  Node2D


@export var country_id:String
@export var is_playable_country:bool = false
var visual_nodes:Array[Polygon2D] = []
var collision_nodes:Array[CollisionPolygon2D] = []
var centers_of_polygons:PackedVector2Array = PackedVector2Array()
var territory_data_list:Dictionary[String,TerritoryData] = {}
#onready
@onready var CollisionArea:Area2D = $CollisionArea
@onready var Visuals:Node2D = $Visuals
@onready var Armys:Node2D = $Army
var neutral_offset_color:Color = GameColors.FriendlyNationColor * 0.5 + Color(randf(),randf(),randf()) * 0.2

# scenes
var playerAgent:PackedScene = preload("res://scenes/objects/infantry.tscn")



func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_redraw()
		RelationManager.build_ready.connect(build_nodes)
		RelationManager.relation_changed.connect(check_relation)

func build_nodes():
	get_territory_data()
	build_territory()
	deploy_army()
	deploy_effects()



func get_territory_data():
	territory_data_list = RelationManager.get_territories_from_country_id(country_id)


func check_relation(id:String,relation:DiplomacyData.relation) -> void:
	if id == country_id:
		change_nodes_color(GameColors.EnemyNationColor if relation == DiplomacyData.relation.war else neutral_offset_color)

func change_nodes_color(color:Color) -> void:
	pass

func deploy_effects():
	if not RelationManager.is_country_owned(country_id): return
	make_particles_effects()

func make_particles_effects():
	pass

func deploy_army():
	for i in centers_of_polygons:
		var tmp:CharacterBody2D = playerAgent.instantiate()
		tmp.global_position = i
		tmp.country_id = country_id
		Armys.add_child(tmp)


func _draw() -> void:
	for i in visual_nodes:
		draw_polyline(i.polygon,Color.WHITE)



func build_territory():
	for territory_id in territory_data_list:
		var territory:TerritoryData = territory_data_list[territory_id]
		build_polygon_centers(territory)
		build_polygon_node(territory.coordinates,name,GameColors.OwnedNationColor if PlayerData.is_country_mine(country_id) else neutral_offset_color)
		build_collision_node(territory.coordinates,name)


func build_polygon_centers(territory:TerritoryData):
	if territory.center == Vector2.ZERO:
		centers_of_polygons.append(center_point_in_polygon(territory.coordinates))
	else:
		centers_of_polygons.append(territory.center)

func build_polygon_node(polygon:PackedVector2Array,node_name:String,node_color:Color):
	var polygonNode:Polygon2D = Polygon2D.new()
	polygonNode.add_to_group("navigation_avoid",true)
	polygonNode.polygon = polygon
	polygonNode.name = node_name
	polygonNode.color = node_color
	visual_nodes.append(polygonNode)
	Visuals.add_child(polygonNode)




func build_collision_node(polygon:PackedVector2Array,node_name:String):
	var collisionNode:CollisionPolygon2D = CollisionPolygon2D.new()
	collisionNode.polygon = polygon
	collisionNode.name = node_name
	collision_nodes.append(collisionNode)

	CollisionArea.add_child(collisionNode)


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
		# Game.popup_territory_action(country_id,get_global_mouse_position())
		RelationManager.territory_clicked(country_id)
