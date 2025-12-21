extends Node2D

var terriroty:PackedScene =  preload("res://scenes/screens/territory.tscn")
const file_path:String  = "res://assets/files/image_data.txt"
var used_colors:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_load_regions()
	#_load_real_map_data()
	_load_real_regions()


func _load_real_regions():
	var countries_list:Array = _load_real_map_data()
	for country in countries_list:
		var vertices_data:Dictionary = _find_vector_list(country)
		if (vertices_data.is_empty()): continue
		var tmpRegion:Area2D = terriroty.instantiate()
		tmpRegion.country_name = country['properties']['shapeName']
		var color:Color = string_to_color(country['properties']['shapeGroup'])
		tmpRegion.color_value = color
		tmpRegion.vertices_data = vertices_data
		$Regions.add_child(tmpRegion)
	#print(json['features'][0]['properties']['shapeName'])

func _find_vector_list(country:Dictionary) -> Dictionary:
	if country['geometry'] == null:
		return {}
	return country['geometry']
	
func string_to_color(text: String) -> Color:
	# Hash the string (32-bit, deterministic)
	var h: int = hash(text)
	
	# Map hash to HSV
	var hue: float = float(h & 0xFFFF) / 65535.0
	var saturation: float = 0.65
	var value: float = 0.85
	
	return Color.from_hsv(hue, saturation, value)

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
	if not FileAccess.file_exists("res://assets/files/simple_geo_zone.txt"):
		print("File not found: ",error_string(FileAccess.get_open_error()))
	
	var file:FileAccess = FileAccess.open("res://assets/files/simple_geo_zone.txt",FileAccess.READ)
	if file == null:
		print("errored")
		file = FileAccess.open("res://assets/files/simple_geo_zone.txt",FileAccess.READ)
		print(error_string(FileAccess.get_open_error()))
	var json:Dictionary = JSON.parse_string(file.get_as_text())
	return json['features']
	#print(json['features'][0]['properties']['shapeName'])
