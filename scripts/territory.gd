extends Area2D


var country_name:String = ""
var vertices_data:Dictionary = {}
@onready var  polygon_node:Polygon2D = $TerrainArea
@onready var collision_polygon_node:CollisionPolygon2D = $CollisinoArea
var selected:bool = false
const x_mul_const:float = 3.555
const y_mul_const:float = -4.0
const x_offset:float = 640
const y_offset:float = 360.0
var color_value:Color = Color.BLACK
	
	


func _ready() -> void:
	if country_name.is_empty()   || vertices_data.is_empty(): return
	_add_polygon()
	_add_collision_polygon()
	queue_redraw()

	

func _add_polygon():
	var vertices_type = vertices_data['type']
	if vertices_type == 'Polygon':
		var vertices:Array = _decode_vertices(vertices_data['coordinates'][0])
		if not is_polygon_valid(vertices):
			return
		polygon_node.polygon = vertices
		polygon_node.color = Color(color_value,RandomNumberGenerator.new().randf_range(0.9,1.0))
		collision_polygon_node.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
		collision_polygon_node.polygon = vertices
	elif (vertices_type == 'MultiPolygon'):
		for a in vertices_data['coordinates']:
			var vertices:Array = _decode_vertices(a[0])
			var polygon:Polygon2D = Polygon2D.new()
			var collisionPolygon:CollisionPolygon2D = CollisionPolygon2D.new()
			if not is_polygon_valid(vertices):
				continue
			collisionPolygon.polygon = vertices
			polygon.polygon = vertices
			polygon.color = Color(color_value,RandomNumberGenerator.new().randf_range(0.9,1.0))
			collisionPolygon.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
			add_child(collisionPolygon)
			add_child(polygon)
	else:
		printerr("error in gettting vetcies type")
		return

func is_polygon_valid(points: Array) -> bool:
	if points.size() < 3:
		return false

	var tris := Geometry2D.triangulate_polygon(points)
	if tris.is_empty():
		return false

	return true


func _decode_vertices(tmp:Array) -> Array:
	var vertices_array:Array = []
	for i in tmp:
		vertices_array.append(Vector2(i[0]*x_mul_const+x_offset,i[1]*y_mul_const+y_offset))
	return vertices_array

func _add_collision_polygon():
	#collision_polygon_node.polygon = vertices
	pass


func _on_mouse_entered() -> void:
	print("mouse found")
	pass
		

func _on_mouse_exited() -> void:
	#polygon_node.color = Color(name)
	pass

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		if event.pressed:
			polygon_node.color = Color.YELLOW
		else:
			polygon_node.color = Color(name)
