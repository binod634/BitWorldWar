extends Node


var vertex:Array[PackedVector2Array] = []
var covering_rect_size:Vector2 = Vector2.ZERO
var covering_rect_position:Vector2 = Vector2.ZERO
var no_grid:int = 0
var grid_status:Array[bool] = []
func _grid_system():
	calculate_covering_rectangle()
	check_grid()



func check_offsets():
	pass

func check_grid():
	var ppc:float = covering_rect_size.x/no_grid
	for a  in no_grid:
		for b in no_grid:
			var check_position = ppc * (no_grid + 0.5)
			var isInside:bool = check_inside(Vector2(check_position,check_position))


func check_inside(pos:Vector2):
	return Geometry2D.is_point_in_polygon(pos,PackedVector2Array())


func calculate_covering_rectangle():
	return Vector2.ZERO
