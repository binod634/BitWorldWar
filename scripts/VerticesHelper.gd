extends Node


const raw_vector_scale_value:Vector2 = Vector2(3.559,-4.0)
const raw_vector_offset_value:Vector2 = Vector2(640.0,360.0)
var countries_vertices_data:Dictionary = {}
var cutter:Polygon2D

func combine_2_polygon_better(polygon1:PackedVector2Array, polygon2:PackedVector2Array) -> Array:
	return Geometry2D.merge_polygons(polygon1, polygon2)

func _make_cutter(vector:PackedVector2Array) -> PackedVector2Array:
	var vertices:PackedVector2Array = find_cutter_polygon(vector)
	cutter.polygon = vertices
	return cutter.polygon


func find_cutter_polygon(vector:PackedVector2Array):
	if vector.size() < 3:
		printerr("Invalid vertices")
		return PackedVector2Array()
	var min_x:float = vector[0].x
	var max_x:float = vector[0].x
	var min_y:float = vector[0].y
	var max_y:float = vector[0].y
	for v in vector:
		min_x = min(min_x, v.x)
		max_x = max(max_x, v.x)
		min_y = min(min_y, v.y)
		max_y = max(max_y, v.y)
	return PackedVector2Array([
		Vector2(min_x, min_y),
		Vector2(max_x, min_y),
		Vector2(max_x, max_y),
		Vector2(min_x, max_y)
	])




func _find_cutted_polygon(
	vector:PackedVector2Array,
):
	return Geometry2D.intersect_polygons(vector, cutter.polygon)



func decode_vertices_from_dict(tmp:Array) -> PackedVector2Array:
	var vertices_array:PackedVector2Array = []
	for i in tmp:
		vertices_array.append(_decode_vertices(i[0],i[1]))
	return vertices_array

func _decode_vertices(x:float,y:float) -> Vector2:
	return Vector2(x*raw_vector_scale_value.x+raw_vector_offset_value.x,y*raw_vector_scale_value.y+raw_vector_offset_value.y)
