extends  Node2D


@export var country_id:String
@export var is_playable_country:bool = false
var visual_nodes:Array[Polygon2D] = []
var collision_nodes:Array[CollisionPolygon2D] = []
var centers_of_polygons:PackedVector2Array = PackedVector2Array()
var territory_data_list:Dictionary[String,TerritoryModel] = {}
#onready
@onready var CollisionArea:Area2D = $CollisionArea
@onready var Visuals:Node2D = $Visuals
@onready var Armys:Node2D = $Army
var neutral_offset_color:Color = GameColors.FriendlyNationColor * 0.5 + Color(randf(),randf(),randf()) * 0.2
var is_owned_nation:bool

# scenes
var playerAgent:PackedScene = preload("res://scenes/objects/infantry.tscn")
var building:PackedScene = preload('res://scenes/tmp/building.tscn')


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_redraw()
		RelationManager.build_ready.connect(build_nodes)
		RelationManager.relation_changed.connect(check_relation)


func build_nodes():
	check_if_owned_nation()
	get_territory_data()
	build_territory()
	deploy_army()
	deploy_effects()
	build_owned_signals()

func check_if_owned_nation():
	is_owned_nation = PlayerData.is_country_mine(country_id)


func build_owned_signals():
	if not  is_owned_nation: return
	InputManager.prompt_building_placement.connect(_prompt_building_placement)


func _prompt_building_placement():
	var tmpBuilding:StaticBody2D = building.instantiate()
	tmpBuilding.global_position = get_global_mouse_position()
	add_child(tmpBuilding)
	print("[*] Building Placed...")

func get_territory_data():
	territory_data_list = RelationManager.get_territories_from_country_id(country_id)


func check_relation(id:String,relation:DiplomacyData.relation) -> void:
	if id == country_id:
		change_nodes_color(GameColors.EnemyNationColor if relation == DiplomacyData.relation.war else neutral_offset_color)

func change_nodes_color(color:Color) -> void:
	for node in visual_nodes:
		node.color = color

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
		var territory:TerritoryModel = territory_data_list[territory_id]
		build_polygon_centers(territory)
		build_polygon_node(territory.coordinates,territory_id,GameColors.OwnedNationColor if is_owned_nation else neutral_offset_color)
		build_collision_node(territory.coordinates,territory_id)


func build_polygon_centers(territory:TerritoryModel):
	if territory.center == Vector2.ZERO:
		centers_of_polygons.append(center_point_in_polygon(territory.coordinates))
	else:
		centers_of_polygons.append(territory.center)

func build_polygon_node(polygon:PackedVector2Array,territory_id:String,node_color:Color):
	var polygonNode:Polygon2D = Polygon2D.new()
	polygonNode.add_to_group("navigation_avoid",true)
	polygonNode.polygon = polygon
	polygonNode.name = territory_id
	polygonNode.color = node_color
	visual_nodes.append(polygonNode)
	Visuals.add_child(polygonNode)




func build_collision_node(polygon:PackedVector2Array,territory_id:String):
	var collisionNode:CollisionPolygon2D = CollisionPolygon2D.new()
	#await get_tree().create_timer(randf() * 10).timeout
	#push_error(node_name)
	#if node_name == "372cb2b53f7e4715ae6605643469d2e8" or node_name == "fb0e6a636d844165a22f57adc96b330d" :
		#print("This is it")
		#collisionNode.polygon = polygon
		#collisionNode.name = node_name
	#else:
	collisionNode.polygon = polygon
	collisionNode.name = territory_id
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
		RelationManager.territory_clicked(country_id,get_territory_id_from_shape_idx(_shape_idx))

func get_territory_id_from_shape_idx(id:int):
	var shape_owner_id: int = CollisionArea.shape_find_owner(id)
	assert(CollisionArea.shape_owner_get_owner(shape_owner_id) is CollisionPolygon2D)
	var shape_owner: CollisionPolygon2D = CollisionArea.shape_owner_get_owner(shape_owner_id)
	return shape_owner.name

func _body_entered(body: Node2D):

	if body.has_method("show_em_up"):
		body.show_em_up()
