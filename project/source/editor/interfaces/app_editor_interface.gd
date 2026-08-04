class_name AppEditorInterface
extends Control
## Base class for the editing interface in the [Editor].

signal closed()

@warning_ignore_start("unused_signal")
## Requests the texture selection popup.
signal texture_popup_requested(
		item_texture: ItemTexture, project_textures: ProjectTextures
)
## Requests the country selection popup.
signal country_select_pressed(item_country: ItemCountry)

signal army_list_item_hovered(army: Army)
signal army_list_item_unhovered()
signal province_list_item_hovered(province: Province)
signal province_list_item_unhovered()
signal decoration_list_item_hovered(decoration: WorldDecoration)
signal decoration_list_item_unhovered()
@warning_ignore_restore("unused_signal")

var project: GameProject

var editor_settings: AppEditorSettings:
	set(value):
		editor_settings = value
		_update_editor_settings()

## Allows this interface to navigate to other interfaces.
var navigator: InterfaceNavigator

var undo_redo: UndoRedo


func _ready() -> void:
	_update_editor_settings()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"editor_close_interface"):
		return
	get_viewport().set_input_as_handled()
	closed.emit()


func _update_editor_settings() -> void:
	pass
