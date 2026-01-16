@tool
extends Node2D

# Territory scene to instantiate for each country
var territory:PackedScene = preload("res://scenes/screens/Territory.tscn")
const REGIONS_FOLDER:String = "res://assets/files/regions_output/"
var territories:Dictionary[String,TerritoryData]
var countries:Dictionary[String,CountryData]
@export_tool_button("Generate Map")var generate_maps:Callable =  build_map
@export_tool_button("Generate Polygon")var generate_polygon:Callable =  build_polygons
@onready var rebuild_needed:bool = $Regions.get_child_count() == 0
@onready var CountriesParent:Node = $Regions
@onready var CountryActionMenu:CanvasLayer = $VisiblityLayer/LeftBarInfo
@onready var DiplomacyDataMenu:CanvasLayer = $VisiblityLayer/RightBarInfo



func _ready() -> void:
	if	not Engine.is_editor_hint():
		decode_all_polygons()
		provide_countries_data()
		register_signals()
		queue_redraw()

func build_map():
	if territories.is_empty():
		decode_all_polygons()
	queue_redraw()


func build_polygons():
	if territories.is_empty():
		decode_all_polygons()
	put_polygons()

func put_polygons():
	for territory_id in territories:
		var polygon:Polygon2D = Polygon2D.new()
		polygon.polygon = territories[territory_id].coordinates
		polygon.color = Color.DARK_SLATE_GRAY
		polygon.add_to_group("navigation_avoid")
		CountriesParent.add_child(polygon)
		#polygon.owner = get_tree().edited_scene_root


func _draw() -> void:
	if not Engine.is_editor_hint(): return
	for territory_id in territories:
		draw_colored_polygon(territories[territory_id].coordinates,Color.DARK_SLATE_GRAY)
		draw_polyline(territories[territory_id].coordinates,Color.WHITE)

func provide_countries_data():
	RelationManager.set_territories(territories)
	RelationManager.set_country_territories_map(countries)
	#RelationManager.pick_nation("75a95d714dc74a54a1c749e10449cd8e")
	RelationManager.pick_nation(find_nation_from_name("Russia"))

func find_nation_from_name(nation_name:String) -> String:
	for a in countries:
		if countries[a].country_name == nation_name:
			return countries[a].country_id
	assert(false,"Why not found ???")
	return "No country found"

func tell_all_countries_to_show_agn():
	for node in CountriesParent.get_children():
		node.build_territory()

func decode_all_polygons():
	print("[*] Decoding all files...")
	var region_files:Array = get_region_files()
	for file_path in region_files:
		var tmpCountries = load_region_file(file_path)
		if tmpCountries == null: printerr("Failed to load country data from %s"%(file_path));continue
		var country_name:String = tmpCountries.get("country", "")
		var country_id:String = tmpCountries.get("id", "")
		var playable:bool = tmpCountries.get('playable',false)
		var regions:Array = tmpCountries.get("regions", [])
		countries[country_id] = CountryData.new(country_name,country_id,PackedStringArray())
		for region in regions:
			if not region.has("id"):printerr("Region without ID in country %s"%(country_name));continue
			var polygon_id = region["id"]
			territories[polygon_id] = TerritoryData.new(region.get("center",[]),region.get("coordinates", [])[0])
			countries[country_id].owned_vertices.append(polygon_id)

		# make country node
		var tmpRegion:Node2D = territory.instantiate()
		tmpRegion.name = country_id
		tmpRegion.country_id = country_id
		tmpRegion.is_playable_country = playable
		CountriesParent.add_child(tmpRegion)


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


func register_signals():
	RelationManager.show_country_action_menu.connect(_show_country_action_menu)
	RelationManager.show_diplomacy_information_menu.connect(_show_diplomacy_information)

func _show_diplomacy_information(data:CountryData):
	DiplomacyDataMenu.set_country_data(data)

func _show_country_action_menu():
	pass
