extends Control

enum ProdClass {
	INFANTRY,
	AIR_PLANE,
	NAVAL_BASE,
	TANK_BASE,
}


@onready var count_label:Label = $MarginContainer/HBoxContainer/Count
var unit_count:int = 0:
	set(value):
		assert(value >= 0)
		unit_count = value
		update_label(value)

var step:int = 1
var infinity:bool = false

func _decrease_count():
	if not unit_count > 0:return
	unit_count -=step

func _increase_count():
	unit_count +=step

func _toggle_infinity():
	infinity = not infinity

func _stop_count():
	infinity = false
	unit_count = 0

func update_label(value:int):
	count_label.text = str(value)
