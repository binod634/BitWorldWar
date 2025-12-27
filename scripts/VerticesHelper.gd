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



# direction is x/y ratio direction=(delta_x/delta_y)
func update_polygon_if_surrounded(
	point:Vector2,
	direction:float,
	cutter_polygons:PackedVector2Array,
	attack_country:PackedVector2Array) -> PackedVector2Array:
		var polygons_inside_cutter:Array = []
		for polygon_name in countries_vertices_data:
			var result:PackedVector2Array = Geometry2D.clip_polygons(attack_country,countries_vertices_data[polygon_name])
			if result.is_empty():
				polygons_inside_cutter.append(polygon_name)
		if len(polygons_inside_cutter) > 1:
			for i in polygons_inside_cutter:
				countries_vertices_data.erase(i)
			_make_new_polygon_from_captured()
		elif (len(polygons_inside_cutter) == 1):
			var r:PackedVector2Array = Geometry2D.exclude_polygons(attack_country,cutter.polygon)
			return r
		return PackedVector2Array()



func _make_new_polygon_from_captured():
	pass

# func _remove_and_update_part_of_captured(points:Vector2):



# # This function will handle the logic of cutting polygons with a line and updating ownership.
# # It should be called every frame (e.g., from _process or similar).
# func update_country_ownership_by_cutter(cutter_line:PackedVector2Array, attacking_country_name:String):
#  # cutter_line: PackedVector2Array of two points representing the cutter's line
#  # attacking_country_name: The name of the country performing the cut

#  # For each country polygon, check if it is intersected by the cutter line
#  for country_polygon_data in countries_vertices_data:
#   var country_polygon:PackedVector2Array = country_polygon_data["vertices"]
#   var country_node:Polygon2D = country_polygon_data["node"]
#   var country_name:String = country_polygon_data["country_name"]

#   # Convert the cutter line into a thin rectangle to use as a polygon cutter
#   var cutter_width:float = 2.0 # You can adjust the thickness of the cutter
#   var dir:Vector2 = (cutter_line[1] - cutter_line[0]).normalized()
#   var perp:Vector2 = Vector2(-dir.y, dir.x)
#   var cutter_poly:PackedVector2Array = PackedVector2Array([
#    cutter_line[0] + perp * cutter_width,
#    cutter_line[0] - perp * cutter_width,
#    cutter_line[1] - perp * cutter_width,
#    cutter_line[1] + perp * cutter_width
#   ])

#   # Intersect the country polygon with the cutter polygon
#   var cut_result:Array = Geometry2D.intersect_polygons(country_polygon, cutter_poly)
#   if cut_result.size() > 0:
#    # The country polygon is cut by the cutter
#    # Remove the cut part from the original country polygon
#    var remaining:Array = Geometry2D.clip_polygons(country_polygon, cutter_poly)
#    if remaining.size() > 0:
#     # Update the original country polygon with the remaining part
#     country_node.polygon = remaining[0]
#     country_polygon_data["vertices"] = remaining[0]
#    else:
#     # The country is fully cut, remove it visually
#     country_node.visible = false

#    # Assign the cut part to the attacking country
#    # You need to have a Polygon2D node for the attacking country
#    var attacker_node:Polygon2D = null
#    for data in countries_vertices_data:
#     if data["country_name"] == attacking_country_name:
#      attacker_node = data["node"]
#      break
#    if attacker_node != null:
#     # Merge the cut part with the attacker's polygon
#     var attacker_poly:PackedVector2Array = attacker_node.polygon
#     for cut_poly in cut_result:
#      attacker_poly = Geometry2D.merge_polygons(attacker_poly, cut_poly)
#     attacker_node.polygon = attacker_poly
#     # Optionally update the attacker's vertices data
#     for data in countries_vertices_data:
#      if data["country_name"] == attacking_country_name:
#       data["vertices"] = attacker_poly

# Example usage:
# Call update_country_ownership_by_cutter(cutter_line, "AttackerCountryName") every frame after updating the cutter line

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
