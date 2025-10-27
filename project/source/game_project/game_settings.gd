class_name GameSettings
## DEPRECATED

var custom_world_limits_enabled: ItemBool
var custom_world_limit_left: ItemInt
var custom_world_limit_right: ItemInt
var custom_world_limit_top: ItemInt
var custom_world_limit_bottom: ItemInt

## Do not overwrite!
var world_limits := WorldLimits.new()

var custom_settings: Dictionary


func _init() -> void:
	custom_world_limits_enabled = ItemBool.new()
	custom_world_limits_enabled.text = "Custom world limits"
	custom_world_limits_enabled.value = false

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

	custom_world_limit_left.value_changed.connect(
		func(_item: ItemInt) -> void:
			if custom_world_limit_left.value >= custom_world_limit_right.value:
				custom_world_limit_left.value = (
						custom_world_limit_right.value - 1
				)
			world_limits.custom_limits.x = custom_world_limit_left.value
	)
	custom_world_limit_top.value_changed.connect(
		func(_item: ItemInt) -> void:
			if custom_world_limit_top.value >= custom_world_limit_bottom.value:
				custom_world_limit_top.value = (
						custom_world_limit_bottom.value - 1
				)
			world_limits.custom_limits.y = custom_world_limit_top.value
	)
	custom_world_limit_right.value_changed.connect(
		func(_item: ItemInt) -> void:
			if custom_world_limit_left.value >= custom_world_limit_right.value:
				custom_world_limit_right.value = (
						custom_world_limit_left.value + 1
				)
			world_limits.custom_limits.z = custom_world_limit_right.value
	)
	custom_world_limit_bottom.value_changed.connect(
		func(_item: ItemInt) -> void:
			if custom_world_limit_top.value >= custom_world_limit_bottom.value:
				custom_world_limit_bottom.value = (
						custom_world_limit_top.value + 1
				)
			world_limits.custom_limits.w = custom_world_limit_bottom.value
	)


func to_dict() -> Dictionary:
	return custom_settings
