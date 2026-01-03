@tool
extends Node2D

# Territory scene to instantiate for each country
var territory:PackedScene = preload("res://scenes/screens/Territory.tscn")
# Folder containing all region polygon JSON files
const REGIONS_FOLDER:String = "res://assets/files/regions_output/"
# Check if rebuild is necessary
@onready var rebuild_needed:bool = $Regions.get_child_count() == 0

# territory polygon data dictionary
@export var territories_data:Dictionary = {}


func _ready() -> void:
	decode_all_polygons()

func decode_all_polygons():
	if not Engine.is_editor_hint():
		return
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
		var color:Color = string_to_color(country_name)
		for region in regions:
			if not region.has("id"):
				printerr("Region without ID in country %s"%(country_name))
				continue
			var polygon_id = region["id"]
			territories_data[polygon_id] = {
				"country_id": country_id,
				"country_name": country_name,
				"polygon_vertices": region.get("coordinates", []),
				"color": color
			}
	# Now instantiate one tmpRegion per polygon using territories_data
	for polygon_id in territories_data.keys():
		var data = territories_data[polygon_id]
		var tmpRegion:Node2D = territory.instantiate()
		tmpRegion.name = polygon_id
		tmpRegion.add_to_group("visual_node_" + String(data.country_id))
		tmpRegion.country_name = data.country_name
		tmpRegion.color_value = data.color
		tmpRegion.vertices_data = data.polygon_vertices
		tmpRegion.country_id = data.country_id
		tmpRegion.polygon_id = polygon_id
		$Regions.add_child(tmpRegion)
		tmpRegion.owner = get_parent().owner	# Set owner for the editor

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
