extends CanvasLayerHUD

@export var AutoHide:bool = true
@onready var ProdHandler:Control = $SizeTheme/MainMenu/Content/Production/VBoxContainer/MarginContainer2/ProdHandler
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


func construct_army_base():
	print("[*] Requesting Army base construction...")

func construct_air_base():
	print("[*] Requesting Air base construction...")


func construct_naval_base():
	print("[*] Requesting Naval base construction...")


func construct_tank_base():
	print("[*] Requesting Tank base construction...")
