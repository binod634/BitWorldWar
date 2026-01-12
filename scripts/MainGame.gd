@tool
extends Node2D

# Territory scene to instantiate for each country
var territory:PackedScene = preload("res://scenes/screens/Territory.tscn")
const REGIONS_FOLDER:String = "res://assets/files/regions_output/"
var territories:Dictionary[String,TerritoryData]
var countries:Dictionary[String,CountryData]
@onready var rebuild_needed:bool = $Regions.get_child_count() == 0
@onready var CountriesParent:Node = $Regions
@onready var BottomInfo:CanvasLayer = $VisiblityLayer/BottomInfoBar
@onready var CountryActionMenu:CanvasLayer = $VisiblityLayer/LeftBarInfo
@onready var DiplomacyDataMenu:CanvasLayer = $VisiblityLayer/RightBarInfo
var testvalue:int
var builded:bool = false

func _ready() -> void:
	if	not Engine.is_editor_hint():
		$VisiblityLayer/BackgroundImage.queue_free()
		decode_all_polygons()
		provide_countries_data()
		register_signals()


func provide_countries_data():
	RelationManager.set_territories(territories)
	RelationManager.set_country_territories_map(countries)

	#RelationManager.pick_nation("75a95d714dc74a54a1c749e10449cd8e")
	RelationManager.pick_nation(find_nation_from_name("India"))

func find_nation_from_name(nation_name:String):
	for a in countries:
		if countries[a].country_name == nation_name:
			print("got nation id %s"%[countries[a].country_id])
			return countries[a].country_id
	assert(false,"Why not found ???")
	return "not found"

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
		#tmpRegion.owner = get_tree().edited_scene_root


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
	print("registered")
	ArmyManager.show_army_command.connect(show_army_actions)
	RelationManager.show_country_action_menu.connect(_show_country_action_menu)
	RelationManager.show_diplomacy_information_menu.connect(_show_diplomacy_information)

func _show_diplomacy_information(data:CountryData):
	DiplomacyDataMenu.set_country_data(data)

func _show_country_action_menu():
	#CountryActionMenu.visible = not CountryActionMenu.visible
	pass

func show_army_actions(status:bool):
	#ArmyCommand.visible = status
	BottomInfo.visible = not status
