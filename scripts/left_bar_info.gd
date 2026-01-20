extends CanvasLayerHUD

enum Layers {
	INFO,
	PRODUCTION_UNIT,
	CONSTRUCTION,
	RESEARCH
}

var curent_layer:Layers = Layers.INFO:
	set(value):
		curent_layer = value
		change_layer(value)
@export var AutoHide:bool = true
@onready var ProdHandler:Control = $SizeTheme/MainMenu/Content/Production/VBoxContainer/MarginContainer2/ProdHandler
@onready var info_node:Control = $SizeTheme/MainMenu/Content/ActionContainer
@onready var production_node:Control = $SizeTheme/MainMenu/Content/Production
#@onready var research_node:Control = $SizeTheme/MainMenu/Content/Research
@onready var building_node:Control = $SizeTheme/MainMenu/Content/Building
var ActionShown:bool = true:
	set(value):
		ActionShown = value

func _ready() -> void:
	super._ready()
	if AutoHide:
		get_tree().create_timer(5).timeout.connect(_hide_self)

func _hide_self():
	visible = false


func add_prod_tab():
	pass

func change_layer(value:Layers):
	# TODO: implement research also
	production_node.visible = false
	info_node.visible = false
	building_node.visible = false
	match  value:
		Layers.INFO:
			info_node.visible = true
		Layers.PRODUCTION_UNIT:
			production_node.visible = true
		Layers.CONSTRUCTION:
			building_node.visible = true



func construct_army_base():
	print("[*] Requesting Army base construction...")
	RelationManager.construct_building(Game.BuildingType.ARMY_BASE)

func construct_air_base():
	print("[*] Requesting Air base construction...")
	RelationManager.construct_building(Game.BuildingType.AIR_BASE)


func construct_naval_base():
	print("[*] Requesting Naval base construction...")
	RelationManager.construct_building(Game.BuildingType.NAVAL_BASE)


func construct_tank_base():
	print("[*] Requesting Tank base construction...")
	RelationManager.construct_building(Game.BuildingType.TANK_BASE)

func button_clicked_production():
	curent_layer = Layers.PRODUCTION_UNIT

func button_clicked_research():
	# TODO: fix it
	return
	curent_layer = Layers.RESEARCH

func button_clicked_construction():
	curent_layer = Layers.CONSTRUCTION


func button_clicked_Info():
	curent_layer = Layers.INFO
