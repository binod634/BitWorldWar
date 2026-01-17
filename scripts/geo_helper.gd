class_name  GeoHelper

const scale_value:float = 2.0
const raw_vector_scale_value:Vector2 = Vector2(3.559,-4.0) * scale_value
const raw_vector_offset_value:Vector2 = Vector2(640.0,360.0) * scale_value

enum  TerritoryData {
	coordinates,
	center,
}

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

static func create_circle_polygon(radius: float,segments: int = 8,offset_position:Vector2 = Vector2.ZERO,color: Color = Color.RED) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.z_index = 1
	var points := generate_circle_points(radius,segments,offset_position)
	poly.polygon = points
	poly.position = offset_position
	poly.color = color
	return poly

static func generate_circle_points(radius:float, segments:int,offset_position:Vector2 = Vector2.ZERO) -> PackedVector2Array:
	var points:PackedVector2Array = PackedVector2Array()
	for i in segments:
		var angle:float = TAU * i/segments
		points.append(Vector2(cos(angle),sin(angle)) * radius + offset_position)
	return points

static func calculate_polygon_area(points: PackedVector2Array) -> float:
	var area := 0.0
	var n := points.size()
	if n < 3:
		return 0.0
	for i in range(n):
		var p1 = points[i]
		var p2 = points[(i + 1) % n]
		area += (p1.x * p2.y) - (p2.x * p1.y)
	return abs(area) / 2.0


static func string_to_color(text: String) -> Color:
	# Hash text using MD5
	var hash_bytes: PackedByteArray = text.md5_buffer()
	var r: int = hash_bytes[0]
	var g: int = hash_bytes[1]
	var b: int = hash_bytes[2]
	return Color(r / 255.0, g / 255.0, b / 255.0) * 0.8 + Color.GREEN * 0.2
