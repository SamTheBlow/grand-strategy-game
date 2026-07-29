class_name InterfaceBackgroundColor
extends AppEditorInterface

var world: GameWorld

var _item_background_color := ItemColor.new()

@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode


func _ready() -> void:
	_item_background_color.text = "Background color"
	_item_background_color.is_transparency_enabled = false
	_item_background_color.value = world.background_color
	_item_background_color.value_changed.connect(_on_item_value_changed)
	world.background_color_changed.connect(_on_background_color_changed)

	_game_settings_node.item.child_items = [_item_background_color]
	_game_settings_node.refresh()


func _on_item_value_changed(_item: ItemColor) -> void:
	undo_redo.create_action("Change background color")
	undo_redo.add_do_property(
			world, &"background_color", _item_background_color.value
	)
	undo_redo.add_undo_property(
			world, &"background_color", world.background_color
	)
	undo_redo.commit_action()


func _on_background_color_changed(_color: Color) -> void:
	_item_background_color.value_changed.disconnect(_on_item_value_changed)
	_item_background_color.value = world.background_color
	_item_background_color.value_changed.connect(_on_item_value_changed)
