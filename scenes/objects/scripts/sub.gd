extends Sprite2D

const OFFSET_ANGLE:float = PI/8
var angle:float = 0.0:
	set(value):
		check_and_change_texture(value)
		angle = value


func check_and_change_texture(value:float):
	var adjusted_value = wrapf(value - OFFSET_ANGLE, 0, TAU)
	var adjusted_angle = wrapf(angle - OFFSET_ANGLE, 0, TAU)
	if int(adjusted_value / (PI / 4)) != int(adjusted_angle / (PI / 4)):
		print("need texture change")
