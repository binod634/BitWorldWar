extends BaseUnit
class_name AirUnit
# # --- AirUnit circling logic ---
# # All AirUnits will rotate in a small circle (radius 4-5 pixels) around their current position.
# # This is purely visual and does not affect navigation/pathfinding.
# # To achieve this, we override _physics_process and add a circling offset to the global_position.
# # If you want to make this optional, you can add a boolean export var (e.g. @export var enable_circling:bool = true)
# # If you want to allow the circle radius to be customized, you can add an export var for that too.

# @export var circle_radius: float = 5.0
# @export var circle_speed: float = 1.5 # radians per second

# var _circle_angle: float = 0.0
# var _base_position: Vector2

# func _ready():
#  _base_position = global_position
#  super._ready()

# func _physics_process(delta):
#  # AirUnit circling logic
#  _circle_angle += circle_speed * delta
#  if _circle_angle > TAU:
#   _circle_angle -= TAU

#  # If moving (has_path), update base position to follow navigation
#  if has_path:
#   _base_position = global_position

#  # Calculate circling offset
#  var offset = Vector2(cos(_circle_angle), sin(_circle_angle)) * circle_radius
#  global_position = _base_position + offset

#  # If you want AirUnits to also move along paths, you can call BaseUnit's _physics_process
#  # and then apply the circling offset on top of the moved position.
#  # Uncomment the following line if you want AirUnits to move AND circle:
#  # ._physics_process(delta)

# # --- If you want to support circling for other unit types, you could move this logic to BaseUnit
# # and enable it via an export var, but for now it's AirUnit-specific.

# # --- In base_unit.gd, if you want to support circling for other units, add:
# # @export var enable_circling: bool = false
# # @export var circle_radius: float = 5.0
# # @export var circle_speed: float = 1.5
# # And move the circling logic into BaseUnit._physics_process, gated by enable_circling.
