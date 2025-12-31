extends Node2D

var raw_coords = [[165.7799, -21.0800], [165.5999, -21.8000], [167.1200, -22.1599], [166.7400, -22.3999], [166.1897, -22.1297], [165.4743, -21.6796], [164.8298, -21.1498], [164.1679, -20.4447], [164.0296, -20.1056], [164.4599, -20.1200], [165.0200, -20.4599], [165.4600, -20.8000]]
var base_polygon: PackedVector2Array = []
var zigzag_polygon: PackedVector2Array = []
var all_points: PackedVector2Array = []

func _ready():
	# 1. Project and Scale
	var offset = Vector2(-164, 20)
	var scale_val = 500
	for c in raw_coords:
		base_polygon.append(Vector2((c[0] + offset.x) * scale_val, (c[1] + offset.y) * -scale_val))

	# 2. Generate Zig-Zag and Points
	generate_zigzag_border(15.0) # 15px intensity
	generate_internal_points(50)

	# 3. Relax to fix small area slivers
	relax_points(5)
	queue_redraw()

func generate_zigzag_border(intensity: float):
	zigzag_polygon.clear()
	for i in range(base_polygon.size()):
		var p1 = base_polygon[i]
		var p2 = base_polygon[(i + 1) % base_polygon.size()]

		# Add the original corner
		zigzag_polygon.append(p1)

		# Add a "midpoint" that is pushed outward or inward
		var mid = (p1 + p2) / 2.0
		var normal = (p2 - p1).orthogonal().normalized()
		var jitter = normal * randf_range(-intensity, intensity)
		zigzag_polygon.append(mid + jitter)

	all_points.append_array(zigzag_polygon)

func generate_internal_points(count: int):
	var bounds = Rect2(base_polygon[0], Vector2.ZERO)
	for p in base_polygon: bounds = bounds.expand(p)

	var added = 0
	while added < count:
		var p = Vector2(randf_range(bounds.position.x, bounds.end.x), randf_range(bounds.position.y, bounds.end.y))
		# Check against base polygon to ensure it's inside the island
		if Geometry2D.is_point_in_polygon(p, base_polygon):
			all_points.append(p)
			added += 1

func relax_points(iterations: int):
	# Mitigation: This moves points to the center of their neighbors,
	# preventing "small area" clusters.
	for r in range(iterations):
		var indices = Geometry2D.triangulate_delaunay(all_points)
		if indices.is_empty(): break

		var new_positions = all_points.duplicate()
		var adjacency = {} # index -> sum of neighbor positions

		for i in range(0, indices.size(), 3):
			var tri = [indices[i], indices[i+1], indices[i+2]]
			for j in range(3):
				var curr = tri[j]
				if not adjacency.has(curr): adjacency[curr] ={"sum": Vector2.ZERO, "count": 0}
				adjacency[curr].sum += all_points[tri[(j+1)%3]] + all_points[tri[(j+2)%3]]
				adjacency[curr].count += 2

		for idx in adjacency:
			# DONT relax the border points, or you lose the zig-zag shape
			if idx < zigzag_polygon.size(): continue

			var avg = adjacency[idx].sum / adjacency[idx].count
			if Geometry2D.is_point_in_polygon(avg, base_polygon):
				new_positions[idx] = avg
		all_points = new_positions

func _draw():
	# Draw the Zig-Zag Coastline
	draw_polyline(zigzag_polygon + PackedVector2Array([zigzag_polygon[0]]), Color.YELLOW, 2.0)

	# Draw the Grid
	var indices = Geometry2D.triangulate_delaunay(all_points)
	for i in range(0, indices.size(), 3):
		var p1 = all_points[indices[i]]
		var p2 = all_points[indices[i+1]]
		var p3 = all_points[indices[i+2]]

		var center = (p1 + p2 + p3) / 3.0
		# Only draw internal cells
		if Geometry2D.is_point_in_polygon(center, base_polygon):
			draw_line(p1, p2, Color.DARK_CYAN, 1.0)
			draw_line(p2, p3, Color.DARK_CYAN, 1.0)
			draw_line(p3, p1, Color.DARK_CYAN, 1.0)
