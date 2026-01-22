@tool
extends Node2D

# Territory scene to instantiate for each country
var country_scene:PackedScene = preload("res://scenes/screens/Country.tscn")
const REGIONS_FOLDER:String = "res://assets/files/regions_output/"
var territories:Dictionary[String,TerritoryModel]
var countries:Dictionary[String,CountryModel]
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
		put_countries()
		register_signals()
		queue_redraw()

func build_map():
	if territories.is_empty():
		decode_all_polygons()
	queue_redraw()


func build_polygons():
	if territories.is_empty():
		decode_all_polygons()
	put_countries()

func put_countries():
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
	WorldManager.set_territories(territories)
	WorldManager.set_country_territories_map(countries)
	#WorldManager.pick_nation("75a95d714dc74a54a1c749e10449cd8e")
	WorldManager.pick_nation(find_nation_from_name("Russia"))

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
		countries[country_id] = CountryModel.new(country_name,country_id,PackedStringArray(),playable)
		for region in regions:
			if not region.has("id"):printerr("Region without ID in country %s"%(country_name));continue
			var polygon_id = region["id"]
			territories[polygon_id] = TerritoryModel.new(region.get("center",[]),region.get("coordinates", [])[0])
			countries[country_id].territories_id.append(polygon_id)

func place_territory():
	for country_id in countries:
		var country:CountryModel = countries[country_id]
		country.set_territory_color(calculate_territory_color(country_id))
		if PlayerData.is_country_mine(country_id):
			country.is_owned_nation = true
		var country_node:Node2D = country_scene.instantiate()
		country_node.country_data = country
		CountriesParent.add_child(country_node)


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
	WorldManager.show_diplomacy_information_menu.connect(_show_diplomacy_information)

func _show_diplomacy_information(data:CountryModel):
	DiplomacyDataMenu.set_country_data(data)

func _show_country_action_menu():
	pass

func calculate_territory_color(country_id:String) -> Color:
	var base_color:Color = GameColors.NationNeutral * 0.6 + Color(randf(),randf(),randf()) * 0.2
	if PlayerData.is_country_mine(country_id):
		base_color = GameColors.OwnedNationColor
	return base_color
