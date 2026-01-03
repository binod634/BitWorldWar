@tool
extends Node2D

# Territory scene to instantiate for each country
var territory:PackedScene = preload("res://scenes/screens/Territory.tscn")
# Folder containing all region polygon JSON files
const REGIONS_FOLDER:String = "res://assets/files/regions_output/"

# territory polygon data dictionary
@export var territories_data:Dictionary = {}
# Check if rebuild is necessary
@onready var rebuild_needed:bool = $Regions.get_child_count() == 0
@onready var CountriesParent:Node = $Regions

func _ready() -> void:
	# no runtime code.
	if Engine.is_editor_hint():
		decode_all_polygons()
	else:
		provide_countries_data()


func provide_countries_data():
	World.set_countries_data(territories_data)

func decode_all_polygons():
	if not rebuild_needed:
		return
	print("Decoding all polygons from region files...")
	var region_files:Array = get_region_files()
	territories_data.clear()
	for file_path in region_files:
		var country_data = load_region_file(file_path)
		if country_data == null:
			printerr("Failed to load country data from %s"%(file_path))
			continue
		var country_name:String = country_data.get("country", "")
		var country_id:String = country_data.get("id", "")
		var regions:Array = country_data.get("regions", [])
		var default_owned_polygons_id:Array = []
		for region in regions:
			if not region.has("id"):
				printerr("Region without ID in country %s"%(country_name))
				continue
			var polygon_id = region["id"]
			var color:Color = string_to_color(country_id) * 0.95 + Color(randf(),randf(),randf()) * 0.05
			default_owned_polygons_id.append(polygon_id)
			territories_data[polygon_id] = {
				"country_id": country_id,
				"country_name": country_name,
				"polygon_vertices": region.get("coordinates", []),
				"color": color
			}
		# make country node
		var tmpRegion:Node2D = territory.instantiate()
		tmpRegion.name = country_id
		tmpRegion.owned_country = country_id
		tmpRegion.default_owned_polygons_id = default_owned_polygons_id
		var territory_owned:Dictionary = {}
		for i in default_owned_polygons_id:
			territory_owned[i] = territories_data[i]
		tmpRegion.owned_territory_data = territory_owned
		tmpRegion.is_playable_country = country_data['playable']
		CountriesParent.add_child(tmpRegion)
		tmpRegion.owner = get_tree().edited_scene_root
		tmpRegion.build_territory()


func get_region_files() -> Array:
	var files:Array = []
	var dir := DirAccess.open(REGIONS_FOLDER)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				files.append(REGIONS_FOLDER + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return files

func load_region_file(file_path:String) -> Dictionary:
	var file:FileAccess = FileAccess.open(file_path, FileAccess.READ)
	assert(file != null,"File not found")
	var json_data = JSON.parse_string(file.get_as_text())
	assert(typeof(json_data) == TYPE_DICTIONARY,"Json data type not dictionary")
	return json_data

func string_to_color(text: String) -> Color:
	# Hash text using MD5
	var hash_bytes: PackedByteArray = text.md5_buffer()
	var r: int = hash_bytes[0]
	var g: int = hash_bytes[1]
	var b: int = hash_bytes[2]
	return Color(r / 255.0, g / 255.0, b / 255.0) * 0.8 + Color.GREEN * 0.2
