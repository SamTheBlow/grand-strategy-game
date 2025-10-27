class_name InterfaceBackgroundColor
extends AppEditorInterface

var _is_setup: bool = false
var _world: GameWorld

var _item_background_color := ItemColor.new()

@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode


func _ready() -> void:
	_item_background_color.text = "Background color"
	_item_background_color.is_transparency_enabled = false
	if _is_setup:
		_update_game_settings()


func setup(world: GameWorld) -> void:
	if _is_setup:
		_world.background_color_changed.disconnect(
				_on_background_color_changed
		)
	else:
		_item_background_color.value_changed.connect(_on_item_value_changed)

	_world = world
	_item_background_color.value = _world.background_color
	_world.background_color_changed.connect(_on_background_color_changed)
	_is_setup = true

	if is_node_ready():
		_update_game_settings()


func _update_game_settings() -> void:
	_game_settings_node.item.child_items = [_item_background_color]
	_game_settings_node.refresh()


func _on_item_value_changed(_item: ItemColor) -> void:
	_world.background_color = _item_background_color.value


func _on_background_color_changed(color: Color) -> void:
	_item_background_color.value = color
