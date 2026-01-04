@tool
extends Node2D

# Territory scene to instantiate for each country
var territory:PackedScene = preload("res://scenes/screens/Territory.tscn")
# Folder containing all region polygon JSON files
const REGIONS_FOLDER:String = "res://assets/files/regions_output/"

# territory polygon data dictionary
@export var territories_data:Dictionary = {}
@export var country_to_territories_map:Dictionary = {}
@export var nation_details_map:Dictionary = {}
# Check if rebuild is necessary
@onready var rebuild_needed:bool = $Regions.get_child_count() == 0
@onready var CountriesParent:Node = $Regions


func _ready() -> void:
	# no runtime code.
	if Engine.is_editor_hint():
		clear_all_data()
		decode_all_polygons()
	else:
		provide_countries_data()
		signal_build_complte()

func clear_all_data():
	territories_data = {}
	country_to_territories_map = {}
	nation_details_map = {}


func signal_build_complte():
	World.signal_setup_completed()


func provide_countries_data():
	World.set_territories_data(territories_data)
	World.set_country_territories_map(country_to_territories_map)
	World.pick_nation(get_id_from_name("India"))

func get_id_from_name(target_name: String) -> String:
	for id in nation_details_map:
		var c_name:String = nation_details_map[id]["name"]
		if c_name == target_name:
			return id
	return "not found"

func tell_all_countries_to_show_agn():
	for node in CountriesParent.get_children():
		node.build_territory()


func decode_all_polygons():
	if not rebuild_needed:
		tell_all_countries_to_show_agn()
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
		if country_name == "India":
			print("found idnai with id: %s"%[country_id])
		var regions:Array = country_data.get("regions", [])
		var default_owned_polygons_id:Array = []
		nation_details_map[country_id] = {
			"name":country_name,
		}
		for region in regions:
			if not region.has("id"):
				printerr("Region without ID in country %s"%(country_name))
				continue
			var polygon_id = region["id"]
			default_owned_polygons_id.append(polygon_id)
			territories_data[polygon_id] = {
				GeoHelper.TerritoryData.center: region.get("center",[]),
				GeoHelper.TerritoryData.coordinates:region.get("coordinates", [])[0]
			}
			if not country_id in country_to_territories_map:
				country_to_territories_map[country_id] = []
			country_to_territories_map[country_id].append(polygon_id)

		# make country node
		var tmpRegion:Node2D = territory.instantiate()
		tmpRegion.name = country_id
		tmpRegion.owned_country = country_id
		tmpRegion.default_owned_polygons_id = default_owned_polygons_id
		var territory_owned:Dictionary = {}
		for i in default_owned_polygons_id:
			territory_owned[i] = territories_data[i]
		tmpRegion.territory_data = territory_owned
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
