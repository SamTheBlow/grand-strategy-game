class_name AppEditorSettings
## The app's editor settings.
##
## Note: do not confuse this with the built-in class [EditorSettings].

var show_world_limits: ItemBool
var world_limits_color: ItemColor


func _init() -> void:
	show_world_limits = ItemBool.new()
	show_world_limits.value = true
	show_world_limits.text = "Show on world map"

	world_limits_color = ItemColor.new()
	world_limits_color.value = Color.RED
	world_limits_color.text = "Color"

	show_world_limits.child_items = [world_limits_color]
	show_world_limits.child_items_on = [0]
