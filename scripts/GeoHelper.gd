class_name  GeoHelper

const raw_vector_scale_value:Vector2 = Vector2(3.559,-4.0)
const raw_vector_offset_value:Vector2 = Vector2(640.0,360.0)

static func decode_vertices_from_dict(tmp:Array) -> PackedVector2Array:
	var vertices_array:PackedVector2Array = []
	for i in tmp:
		vertices_array.append(decode_vertices(i[0],i[1]))
	return vertices_array

static func decode_vertices(x:float,y:float) -> Vector2:
	return Vector2(x*raw_vector_scale_value.x+raw_vector_offset_value.x,y*raw_vector_scale_value.y+raw_vector_offset_value.y)

static func decode_all_vertices(vertices_data:Dictionary) -> Array[PackedVector2Array]:
	if vertices_data.is_empty(): printerr("No data in vertices");return []
	var country_lands:Array[PackedVector2Array] = []
	var vertices_type = vertices_data['geometry']['type']
	if vertices_type == "Polygon":
		country_lands.append(decode_vertices_from_dict(vertices_data['geometry']["coordinates"][0]))
	elif vertices_type == "MultiPolygon":
		for coords in vertices_data['geometry']["coordinates"]:
			country_lands.append(decode_vertices_from_dict(coords[0]))
	return country_lands
