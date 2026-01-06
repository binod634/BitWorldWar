extends Node

signal show_army_command(status:bool)

var selected_army:Array = []


func add_army_to_selection(node:CharacterBody2D):
	selected_army.append(node)
	show_army_action(not selected_army.is_empty())


func remove_army_from_selection(node:CharacterBody2D):
	if OS.is_debug_build():
		assert(node in selected_army,"node not found in selection")
	if node in selected_army:
		selected_army.erase(node)
	show_army_action(not selected_army.is_empty())

func clear_army_selection():
	for a in selected_army:
		a.reset_selection()
	selected_army = []
	show_army_action(false)

func got_location_point(point_position:Vector2):
	for a in selected_army:
		a.target_position = point_position


func show_army_action(status:bool):
	print("got action signal %s"%[status])
	show_army_command.emit(status)
