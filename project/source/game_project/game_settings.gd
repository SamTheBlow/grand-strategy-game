class_name GameSettings
## Information about a [GameProject] that has no effect on the game's
## internal logic, but still affects the user experience (e.g. visuals).
##
## These settings must not change while an ongoing game is using them.

var custom_world_limits_enabled: ItemBool
var custom_world_limit_left: ItemInt
var custom_world_limit_right: ItemInt
var custom_world_limit_top: ItemInt
var custom_world_limit_bottom: ItemInt

## Do not overwrite! This is initialized automatically.
var world_limits: WorldLimits

var custom_settings: Dictionary


func _init() -> void:
	custom_world_limits_enabled = ItemBool.new()
	custom_world_limits_enabled.value = false
	custom_world_limits_enabled.text = "Custom world limits"

	custom_world_limit_left = ItemInt.new()
	custom_world_limit_left.text = "Left"
	custom_world_limit_left.value = WorldLimits.DEFAULT_LEFT

	custom_world_limit_right = ItemInt.new()
	custom_world_limit_right.text = "Right"
	custom_world_limit_right.value = WorldLimits.DEFAULT_RIGHT

	custom_world_limit_top = ItemInt.new()
	custom_world_limit_top.text = "Top"
	custom_world_limit_top.value = WorldLimits.DEFAULT_TOP

	custom_world_limit_bottom = ItemInt.new()
	custom_world_limit_bottom.text = "Bottom"
	custom_world_limit_bottom.value = WorldLimits.DEFAULT_BOTTOM

	custom_world_limits_enabled.child_items = [
		custom_world_limit_left,
		custom_world_limit_right,
		custom_world_limit_top,
		custom_world_limit_bottom,
	]
	custom_world_limits_enabled.child_items_on = [0, 1, 2, 3]

	world_limits = WorldLimits.new().with_values(
			custom_world_limit_left.value,
			custom_world_limit_top.value,
			custom_world_limit_right.value,
			custom_world_limit_bottom.value
	)
	custom_world_limit_left.value_changed.connect(
		func(property: ItemInt) -> void:
			world_limits.limit_left = property.value
	)
	custom_world_limit_top.value_changed.connect(
		func(property: ItemInt) -> void:
			world_limits.limit_top = property.value
	)
	custom_world_limit_right.value_changed.connect(
		func(property: ItemInt) -> void:
			world_limits.limit_right = property.value
	)
	custom_world_limit_bottom.value_changed.connect(
		func(property: ItemInt) -> void:
			world_limits.limit_bottom = property.value
	)


## Adjusts settings to match given world limits.
func load_world_limits(input_limits: WorldLimits) -> void:
	custom_world_limits_enabled.value = true
	custom_world_limit_left.value = input_limits.limit_left
	custom_world_limit_right.value = input_limits.limit_right
	custom_world_limit_top.value = input_limits.limit_top
	custom_world_limit_bottom.value = input_limits.limit_bottom


func to_dict() -> Dictionary:
	return custom_settings
