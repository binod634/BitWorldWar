@tool
extends Node2D


# territory buildign for each nations.
var terriroty:PackedScene =  preload("res://scenes/screens/territory.tscn")
# file to build nations
const file_path:String  = "res://assets/files/simple_countries.json"
# check if rebuild is necessary
@onready var rebuild_needed:bool = $Regions.get_child_count()  == 0


func _ready() -> void:
	print(Geometry2D.offset_polygon(PackedVector2Array([Vector2(0,0),Vector2(100,0),Vector2(100,100),Vector2(0,100)]),2.0))
	_rebuild_node_in_editor_if_necessary()
	start_game()


func start_game():
	if not Engine.is_editor_hint():
		Game.start_game()

func _rebuild_node_in_editor_if_necessary():
	if rebuild_needed &&  Engine.is_editor_hint():
		print("Rebuilding nodes...")
		_load_and_add_nodes()


func _make_avoidance_regions_for_sea(vectors:PackedVector2Array):
	var avoid:NavigationObstacle2D = NavigationObstacle2D.new()
	avoid.vertices = vectors
	avoid.affect_navigation_mesh = true
	avoid.carve_navigation_mesh = true
	$WorldNavigation/SeaNavigation.add_child(avoid)



func _load_and_add_nodes():
	var countries_list:Array = load_regions_file()
	for country in countries_list:
		var tmpRegion:Node2D = terriroty.instantiate()
		var color:Color = string_to_color(country['shapeName'])
		var hashed_name:String = country['shapeName'].md5_text()
		var country_name:String = country['shapeName']
		tmpRegion.name = hashed_name.md5_text()
		tmpRegion.add_to_group("visual_node_" + hashed_name)
		tmpRegion.country_name = country_name
		tmpRegion.color_value = color
		tmpRegion.vertices_data = country
		$Regions.add_child(tmpRegion)
		tmpRegion.owner = get_tree().edited_scene_root

		# add in global script
		#Game.add_countries(country)



func string_to_color(text: String) -> Color:
	# Hash text using MD5
	var hash_bytes: PackedByteArray = text.md5_buffer()
	var r_int: int = (hash_bytes[0] << 24) | (hash_bytes[1] << 16) | (hash_bytes[2] << 8) | hash_bytes[3]
	var g_int: int = (hash_bytes[4] << 24) | (hash_bytes[5] << 16) | (hash_bytes[6] << 8) | hash_bytes[7]
	var b_int: int = (hash_bytes[8] << 24) | (hash_bytes[9] << 16) | (hash_bytes[10] << 8) | hash_bytes[11]
	var r: float = float(r_int & 0xFFFFFFFF) / 4294967295.0
	var g: float = float(g_int & 0xFFFFFFFF) / 4294967295.0
	var b: float = float(b_int & 0xFFFFFFFF) / 4294967295.0
	return Color(clamp(r, 0.0, 1.0), clamp(g, 0.0, 1.0), clamp(b, 0.0, 1.0))


func load_regions_file():
	var file:FileAccess = FileAccess.open(file_path,FileAccess.READ)
	if file == null:
		print("errored")
		return
	return JSON.parse_string(file.get_as_text())
