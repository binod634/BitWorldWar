extends CanvasLayerHUD

# properties
enum PanelMode {
	BuildingPlacement,
	NormalInformation,
}
var currentPanelMode:PanelMode = PanelMode.NormalInformation:
	set(value):
		currentPanelMode = value
		update_panel(value)


# panels onready
@onready var NodePanelNormalInformation:MarginContainer = $SizeTheme/NormalInformation

func _ready() -> void:
	super._ready()

func update_panel(panelMode:PanelMode):
	match panelMode:
		PanelMode.NormalInformation:
			pass
		PanelMode.BuildingPlacement:
			pass
