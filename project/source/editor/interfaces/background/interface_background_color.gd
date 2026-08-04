class_name InterfaceBackgroundColor
extends AppEditorInterface

@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode
@onready var _item := _game_settings_node.item.child_items[0] as ItemColor


func _ready() -> void:
	_item.value = project.game.world.background_color
	_item.value_changed.connect(_on_item_value_changed)
	project.game.world.background_color_changed.connect(
			_on_background_color_changed
	)

	closed.connect(navigator.close_interface)


func _on_item_value_changed(_item_color: ItemColor) -> void:
	undo_redo.create_action("Change background color")
	undo_redo.add_do_property(
			project.game.world, &"background_color", _item.value
	)
	undo_redo.add_undo_property(
			project.game.world,
			&"background_color",
			project.game.world.background_color
	)
	undo_redo.commit_action()


func _on_background_color_changed(_color: Color) -> void:
	_item.value_changed.disconnect(_on_item_value_changed)
	_item.value = project.game.world.background_color
	_item.value_changed.connect(_on_item_value_changed)
