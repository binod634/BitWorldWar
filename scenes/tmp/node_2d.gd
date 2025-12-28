extends Node2D


var poly:Array = [Vector2(0,0),Vector2(0,80),Vector2(120,80),Vector2(120,0),]
var tmp:Polygon2D = Polygon2D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vectors:PackedVector2Array = PackedVector2Array([Vector2(0,0),Vector2(0,80),Vector2(120,80),Vector2(120,0),])
	var tt = Geometry2D.offset_polygon(poly,100)
	print(vectors)
	tmp.color = Color.RED
	tmp.polygon = tt[0]
	tmp.global_position = Vector2(100,100)
	add_child(tmp)
