extends Node2D

var x_index: float = 1280
@onready var polygon: Polygon2D = $Polygon2D
@onready var polygon_cutter: Polygon2D = $Polygon2D2

func _process(_delta: float) -> void:
	# 1. Move the cutter node
	polygon_cutter.position -= Vector2(1, 0)

	# 2. Get the cutter's points in the same space as the main polygon
	var cutter_global_points = get_cutter_points_in_world_space()

	# 3. Perform the clip on the .polygon (singular) property
	var result = Geometry2D.clip_polygons(polygon.polygon, cutter_global_points)

	# 4. Update the main polygon if a result exists
	if result.size() > 0:
		# Note: If the cut splits the polygon into two pieces,
		# result[0] is the first piece.
		polygon.polygon = result[0]

func get_cutter_points_in_world_space() -> PackedVector2Array:
	var trans_points = PackedVector2Array()
	# Transform each local vertex of the cutter by its current position/rotation
	for vertex in polygon_cutter.polygon:
		trans_points.append(polygon_cutter.transform * vertex)
	return trans_points
