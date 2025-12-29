extends Node2D

@export var polygons:Array[PackedVector2Array] 
var nodes:Array[Polygon2D]
var beep_timer:Timer = Timer.new()
var beepticker:bool = false

func _ready() -> void:
	# calculate proper areas
	make_nodes()
	activate_beep_timer()


func activate_beep_timer():
	beep_timer.wait_time = 0.1
	beep_timer.one_shot = false
	beep_timer.autostart = true
	beep_timer.timeout.connect(make_beep)
	add_child(beep_timer)
	
func make_beep():
	for node in nodes:
		node.color = Color.RED if beepticker else Color.TRANSPARENT
	beepticker = !beepticker

func make_nodes():
	# no work when polygons is empty.
	if  polygons.is_empty(): return
	for i in polygons:
		# vertices < 3, invalid
		if i.size() < 3: continue
		var tmp:Polygon2D = Polygon2D.new()
		tmp.polygon = i
		add_child(tmp)
		nodes.append(tmp)
