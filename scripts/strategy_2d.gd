@tool
extends Node2D

var terriroty:PackedScene =  preload("res://scenes/screens/territory.tscn")
const file_path:String  = "res://assets/files/simple_countries.json"
@onready var  rebuild_scene_identifier:Node2D = $"Regions/5882b568d8a010ef48a6896f53b6eddb"
var timer:Timer = Timer.new()

func _ready() -> void:
	# nothing to run on runtime.game
	if not Engine.is_editor_hint():
		return
		
	# render map if there isn't any
	if not rebuild_scene_identifier: 
		_load_real_regions()
		timer.wait_time = 5
		timer.autostart = true
		timer.one_shot = true
		timer.timeout.connect(func ():
			print("starting baking")
			$WorldNavigation.bake_navigation_polygon()
			print("baking ending")
		)
		add_child(timer)
	
	
	return

func _make_avoidance_regions(vectors:PackedVector2Array):
	var avoid:NavigationObstacle2D = NavigationObstacle2D.new()
	avoid.vertices = vectors
	avoid.affect_navigation_mesh = true
	avoid.carve_navigation_mesh = true
	$WorldNavigation.add_child(avoid)
	avoid.owner = get_tree().edited_scene_root

	

func _load_real_regions():
	var countries_list:Array = _load_real_map_data()
	#print(countries_list)
	for country in countries_list:
		var tmpRegion:Area2D = terriroty.instantiate()
		var color:Color = string_to_color(country['shapeName'])
		tmpRegion.name = country['shapeName'].md5_text()
		tmpRegion.add_avoidance.connect(_make_avoidance_regions)
		$Regions.add_child(tmpRegion)
		tmpRegion.owner = get_tree().edited_scene_root
		tmpRegion.color_value = color
		tmpRegion.country_name = country['shapeName']
		tmpRegion.vertices_data = country
		tmpRegion.do_everything_on_editor_rebuild()
#
#func string_to_color(text: String) -> Color:
	## Hash the string (32-bit, deterministic)
	#var h: int = hash(text)
	#
	## Map hash to HSV
	#var hue: float = float(h & 0xFFFF) / 65535.0
	#var saturation: float = 0.65
	#var value: float = 0.85
	#
func string_to_color(text: String) -> Color:
	# Hash text using MD5
	var hash_bytes: PackedByteArray = text.md5_buffer()

	# Convert first 12 bytes to three 32-bit integers
	var r_int: int = (hash_bytes[0] << 24) | (hash_bytes[1] << 16) | (hash_bytes[2] << 8) | hash_bytes[3]
	var g_int: int = (hash_bytes[4] << 24) | (hash_bytes[5] << 16) | (hash_bytes[6] << 8) | hash_bytes[7]
	var b_int: int = (hash_bytes[8] << 24) | (hash_bytes[9] << 16) | (hash_bytes[10] << 8) | hash_bytes[11]

	# Map to 0-1 range
	var r: float = float(r_int & 0xFFFFFFFF) / 4294967295.0
	var g: float = float(g_int & 0xFFFFFFFF) / 4294967295.0
	var b: float = float(b_int & 0xFFFFFFFF) / 4294967295.0

	return Color(clamp(r, 0.0, 1.0), clamp(g, 0.0, 1.0), clamp(b, 0.0, 1.0))

func get_pixel_color(img:Image) -> Dictionary:
	var pixel_color_dist:Dictionary = {}
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var pixel_color = str(img.get_pixel(x,y).to_html(false))
			if pixel_color == 'fafafa':
				continue
			if pixel_color not in pixel_color_dist:
				pixel_color_dist[pixel_color] = []
			pixel_color_dist[pixel_color].append(Vector2(x,y))
	return pixel_color_dist


func _import_file(filepath:String) -> Array:
	var file = FileAccess.open(filepath,FileAccess.READ)
	# failsafe on file error
	if file == null:
		printerr("can't open file")
		return []

	return JSON.parse_string(file.get_as_text())

func _load_real_map_data():
	if not FileAccess.file_exists(file_path):
		print("File not found: ",error_string(FileAccess.get_open_error()))
		return
	var file:FileAccess = FileAccess.open(file_path,FileAccess.READ)
	if file == null:
		print("errored")
		file = FileAccess.open(file_path,FileAccess.READ)
		print(error_string(FileAccess.get_open_error()))
	return JSON.parse_string(file.get_as_text())
