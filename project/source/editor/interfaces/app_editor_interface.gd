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
## Requests that given army be selected.
signal army_select_requested(army: Army)

signal province_list_item_hovered(province: Province)
signal province_list_item_unhovered()
## Requests that given province be selected.
signal province_select_requested(province: Province)

signal decoration_list_item_hovered(decoration: WorldDecoration)
signal decoration_list_item_unhovered()
## Requests that given decoration be selected.
signal decoration_select_requested(decoration: WorldDecoration)
@warning_ignore_restore("unused_signal")

## Specific signal to emit when this interface is closed. May be empty.
var closed_signal: Signal

var project: GameProject
var editor_settings: AppEditorSettings
var navigator: InterfaceNavigator
var undo_redo: UndoRedoResource


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"editor_close_interface"):
		get_viewport().set_input_as_handled()
		closed.emit()
	if event.is_action_pressed(&"delete"):
		_delete()
	if event.is_action_pressed(&"duplicate"):
		_duplicate()


func close() -> void:
	closed.emit()


## Duplicates given node's item so that it isn't shared between interfaces.
func _setup_settings(settings_node: ItemVoidNode) -> void:
	settings_node.item = settings_node.item.duplicate_deep() as PropertyTreeItem
	_load_settings(settings_node.item)
	settings_node.refresh()


## Override this function in a subclass to load settings and connect signals.
func _load_settings(_settings_item: PropertyTreeItem) -> void:
	pass


func _apply_undo_redo_property(
		description: String,
		object: Object,
		property_name: StringName,
		old_value: Variant,
		new_value: Variant
) -> void:
	undo_redo.create_action(description)
	undo_redo.add_do_property(object, property_name, new_value)
	undo_redo.add_undo_property(object, property_name, old_value)
	undo_redo.commit_action()


func _apply_undo_redo_method(
		description: String, do_callable: Callable, undo_callable: Callable
) -> void:
	undo_redo.create_action(description)
	undo_redo.add_do_method(do_callable)
	undo_redo.add_undo_method(undo_callable)
	undo_redo.commit_action()


## Sets the value of given item without triggering given callable.
## Prevents infinite loops and redundant undo_redo actions.
func _set_setting_no_signal(
		item: PropertyTreeItem, callable: Callable, value: Variant
) -> void:
	item.value_changed.disconnect(callable)
	if item is ItemVector2:
		item.set_data(value)
	elif item is ItemOptions:
		item.selected_index = value
	else:
		item.value = value
	item.value_changed.connect(callable)


## Override this function to delete something.
func _delete() -> void:
	pass


## Override this function to duplicate something.
func _duplicate() -> void:
	pass
