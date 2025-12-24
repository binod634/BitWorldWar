@tool
extends Area2D

signal add_avoidance(vertices)


var country_label:PackedScene = preload("res://scenes/components/country_label.tscn")
var country_lands:Dictionary = {}
var lands_count:int = 0
@export var is_playable:bool = false
@export var vertices_data:Dictionary = {}
const collision_polygon_minimum_distance_allowded:float = 1
@export var color_value:Color = Color.BLACK
var raw_vector_scale_value:Vector2 = Vector2(3.559,-4.0)
var raw_vector_offset_value:Vector2 = Vector2(640.0,360.0)
@export var country_name:String = ""
var capital_name:String = ""
var center_of_country:Vector2 = Vector2.ZERO
var capital_position:Vector2 = Vector2.ZERO


func _ready() -> void:
	# not to be executed when on editor.
	if  Engine.is_editor_hint():
		return
	_decode_all_vertices()
	_add_map_visible_layer_with_collision()
	#_make_capital()
	_put_marking_on_capital()
	#_calculate_overall_center()
	#_show_country_label()
	
func do_everything_on_editor_rebuild():
	_decode_all_vertices()
	_add_map_visible_layer_with_collision()
	#_make_capital()
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
	add_child(tmp)

	
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
	polygon2d.polygon = clean_vertices
	add_child(polygon2d)
	
	add_avoidance.emit(clean_vertices)

		
	
func _clean_vectors(tmpvectors:PackedVector2Array) -> PackedVector2Array:
	diagnose_collision_polygon(tmpvectors)
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
	add_child(polygon2d)


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
	add_child(create_circle_polygon(1.0,capital_position,16))


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
	
	

func diagnose_collision_polygon(poly: PackedVector2Array, eps := 0.001) -> Dictionary:
	var report := {
		"ok": true,
		"errors": [],
		"warnings": [],
		"stats": {}
	}

	# --- Basic size check ---
	if poly.size() < 3:
		report.ok = false
		printerr("Polygon has fewer than 3 vertices")
		return report

	# --- Duplicate & near-duplicate points ---
	for i in range(poly.size()):
		for j in range(i + 1, poly.size()):
			if poly[i].distance_to(poly[j]) < eps:
				report.ok = false
				printerr(
					"Duplicate or near-duplicate vertices at indices %d and %d" % [i, j]
				)

	# --- Collinear consecutive points ---
	for i in range(poly.size()):
		var a := poly[i]
		var b := poly[(i + 1) % poly.size()]
		var c := poly[(i + 2) % poly.size()]
		var ab := b - a
		var bc := c - b
		if abs(ab.cross(bc)) < eps:
			report.warnings.append(
				"Collinear points at indices %d, %d, %d" % [i, i + 1, i + 2]
			)

	# --- Winding order ---
	var clockwise := Geometry2D.is_polygon_clockwise(poly)
	report.stats["clockwise"] = clockwise
	if clockwise:
		report.warnings.append("Polygon is clockwise (CollisionPolygon2D expects CCW)")

	# --- Area check ---
	var area := get_polygon_area(poly)
	report.stats["area"] = area
	if abs(area) < eps:
		report.ok = false
		printerr("Polygon area is zero or near-zero")

	# --- Self-intersection ---
	if not _is_polygon_simple(poly):
		report.ok = false
		printerr("Polygon is self-intersecting (not simple)")

	# --- Convex decomposition test ---
	var convex_parts := Geometry2D.decompose_polygon_in_convex(poly)
	report.stats["convex_parts"] = convex_parts.size()
	if convex_parts.is_empty():
		report.ok = false
		printerr("Godot convex decomposition failed")

	return report

func normalize_geojson_ring(ring: PackedVector2Array, eps := 0.001) -> PackedVector2Array:
	var out := PackedVector2Array()

	if ring.size() < 3:
		return out

	# Remove closing duplicate (GeoJSON style)
	if ring[0].distance_to(ring[-1]) < eps:
		ring = ring.slice(0, ring.size() - 1)

	# Remove consecutive duplicates
	for v in ring:
		if out.is_empty() or out[-1].distance_to(v) > eps:
			out.append(v)

	return out


func _is_polygon_simple(poly: PackedVector2Array,) -> bool:
	var n := poly.size()
	if n < 3:
		return false

	for i in range(n):
		var a1 := poly[i]
		var a2 := poly[(i + 1) % n]

		for j in range(i + 1, n):
			# Skip adjacent edges and shared vertices
			if abs(i - j) <= 1:
				continue
			if i == 0 and j == n - 1:
				continue

			var b1 := poly[j]
			var b2 := poly[(j + 1) % n]

			var hit = Geometry2D.segment_intersects_segment(a1, a2, b1, b2)
			if hit != null:
				return false

	return true



#func _make_vertices(coords:Array) -> void:
	#var vertices:PackedVector2Array = _decode_vertices_from_dict(coords)
	#if not is_polygon_valid(vertices):
		#return PackedVector2Array()
#
	#var clean_vertices:PackedVector2Array = _clean_vertices(vertices)
	#
	## Create Polygon2D
	#var polygon:Polygon2D = Polygon2D.new()
	#polygon.polygon = vertices
	#polygon.color = Color(color_value, RandomNumberGenerator.new().randf_range(1 - deviation, 1.0))
	#add_child(polygon)
	#
	## Create CollisionPolygon2D
	#var collision_polygon:CollisionPolygon2D = CollisionPolygon2D.new()
	#collision_polygon.polygon = clean_vertices
	#collision_polygon.build_mode = CollisionPolygon2D.BUILD_SOLIDS
	#collision_polygon.set_deferred("input_pickable", true)
	#add_child(collision_polygon)
#
	## Make copies with offset
	#var offset:Vector2 = Vector2(1280, 0)
	#_make_copy_with_extra_position(polygon.duplicate(), offset)
	#_make_copy_with_extra_position(polygon.duplicate(), -offset)
	#_make_copy_with_extra_position(collision_polygon.duplicate(), offset)
	#_make_copy_with_extra_position(collision_polygon.duplicate(), -offset)
	#
	#
	#
#
#
#
#
#func _add_polygon_from_coords(coords:Array) -> void:
	#var vertices:PackedVector2Array = _decode_vertices_from_dict(coords)
	#if not is_polygon_valid(vertices):
		#return
#
	#var clean_vertices:PackedVector2Array = _clean_vertices(vertices)
	#
	## Create Polygon2D
	#var polygon:Polygon2D = Polygon2D.new()
	#polygon.polygon = vertices
	#polygon.color = Color(color_value, RandomNumberGenerator.new().randf_range(1 - deviation, 1.0))
	#add_child(polygon)
	#
	## Create CollisionPolygon2D
	#var collision_polygon:CollisionPolygon2D = CollisionPolygon2D.new()
	#collision_polygon.polygon = clean_vertices
	#collision_polygon.build_mode = CollisionPolygon2D.BUILD_SOLIDS
	#collision_polygon.set_deferred("input_pickable", true)
	#add_child(collision_polygon)
#
	## Make copies with offset
	#var offset:Vector2 = Vector2(1280, 0)
	#_make_copy_with_extra_position(polygon.duplicate(), offset)
	#_make_copy_with_extra_position(polygon.duplicate(), -offset)
	#_make_copy_with_extra_position(collision_polygon.duplicate(), offset)
	#_make_copy_with_extra_position(collision_polygon.duplicate(), -offset)
#
#
#func _make_copy_with_extra_position(node:Node2D,vector:Vector2):
	#node.position += vector
	#add_child(node)
#
#func is_polygon_valid(points: PackedVector2Array) -> bool:
	#if points.size() < 3:
		#return false
#
	#var tris := Geometry2D.triangulate_polygon(points)
	#if tris.is_empty():
		#return false
	#return true
#
#
#
#
#func _clean_vertices(vectors:PackedVector2Array) -> PackedVector2Array:
#
	#var old:Vector2 = vectors[0]
	#var cleaned:PackedVector2Array = [old]
	#for i in vectors:
		#if i == old: continue
		#if old.distance_to(i) > collision_polygon_minimum_distance_allowded:
			#cleaned.append(i)
	#return cleaned if len(cleaned) > 2 else PackedVector2Array()
	##print("len old: %s and len new: %s"%[len(vectors),len(cleaned)])
#
#
#
#func get_aabb(vertices:PackedVector2Array) -> Rect2:
	#var min_x:float = vertices[0].x
	#var max_x:float = vertices[0].x
	#var min_y:float = vertices[0].y
	#var max_y:float = vertices[0].y
	#for v in vertices:
		#min_x = min(min_x, v.x)
		#max_x = max(max_x, v.x)
		#min_y = min(min_y, v.y)
		#max_y = max(max_y, v.y)
	#return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
#
#
#
#func get_aabb_vertices(vertices:PackedVector2Array) -> PackedVector2Array:
	#var rect:Rect2 = get_aabb(vertices)
	#return PackedVector2Array([
		#rect.position,
		#rect.position + Vector2(rect.size.x, 0),
		#rect.position + rect.size,
		#rect.position + Vector2(0, rect.size.y)
	#])
#
#
#func _avg_vertices(vertices:PackedVector2Array) -> Vector2:
	#if (len(vertices) < 3):
		#if len(vertices) == 0: return Vector2.ZERO
		#if len(vertices) ==  1: return vertices[0]
	#var sumVector:Vector2 = Vector2.ZERO
	#for i in vertices:
		#sumVector +=i
	#return sumVector/len(vertices)
#
#
#func  _find_center_position(vectors:PackedVector2Array) -> Vector2:
	#var sums:Vector2 = Vector2.ZERO
	#for a in vectors:
		#sums +=a
	#return sums/len(vectors)
