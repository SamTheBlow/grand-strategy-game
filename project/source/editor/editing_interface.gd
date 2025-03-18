class_name EditingInterface
extends Control
## Hides itself when the interface is closed,
## shows itself when the interface is open.

enum InterfaceType {
	WORLD_LIMITS = 0,
	BACKGROUND_COLOR = 1,
	DECORATION = 2,
}

## The root node of each scene is an [AppEditorInterface].
const _INTERFACE_SCENES: Dictionary[InterfaceType, PackedScene] = {
	InterfaceType.WORLD_LIMITS: preload("uid://cyspbdausxgwr"),
	InterfaceType.BACKGROUND_COLOR: preload("uid://bb53mhx3u8ho8"),
	InterfaceType.DECORATION: preload("uid://bql3bs1c3rgo3"),
}

var _current_interface: Node:
	set(value):
		_current_interface = value
		_update_visibility()

@onready var _contents_container: Node = %Contents


func _ready() -> void:
	_update_visibility()


## Opens interface with given type.
## Closes the already open interface if applicable.
func open_interface(
		type: InterfaceType,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	if not _INTERFACE_SCENES.has(type):
		push_error("Can't find the scene for this interface type.")
		return

	close_interface()

	var new_interface := (
			_INTERFACE_SCENES[type].instantiate() as AppEditorInterface
	)
	new_interface.editor_settings = editor_settings
	new_interface.game_settings = project.settings
	_contents_container.add_child(new_interface)
	_current_interface = new_interface


## Has no effect if there is no interface open.
func close_interface() -> void:
	if _current_interface == null:
		return
	_current_interface.get_parent().remove_child(_current_interface)
	_current_interface.queue_free()
	_current_interface = null


func _update_visibility() -> void:
	visible = _current_interface != null
