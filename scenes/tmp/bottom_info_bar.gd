extends CanvasLayer

@onready var NationDock:Control = $Sizing/ContainWithin/NationData
@onready var ArmyDock:Control = $Sizing/ContainWithin/ArmyData
@export var war_with_nations:PackedStringArray = PackedStringArray()

# varaible
enum DockType {
	Infantry,
	Country,
}

var dockOpened:DockType = DockType.Infantry:
	set(value):
		dockOpened = value
		change_dock_type(value)

func disable_all_dock():
	NationDock.visibe = false
	ArmyDock.visible = false

func change_dock_type(type:DockType):
	disable_all_dock()


func show_dock(type:DockType):
	match type:
		pass

	if type == DockType.Infantry:
		ArmyDock.visible = true
