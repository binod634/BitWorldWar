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
	var r: int = hash_bytes[0]
	var g: int = hash_bytes[1]
	var b: int = hash_bytes[2]
	return Color(r / 255.0, g / 255.0, b / 255.0) * 0.8 + Color.GREEN * 0.2


func load_regions_file():
	var file:FileAccess = FileAccess.open(file_path,FileAccess.READ)
	if file == null:
		print("errored")
		return
	return JSON.parse_string(file.get_as_text())
