class_name EditingInterface
extends Control
## Hides itself when the interface is closed,
## shows itself when the interface is open.

enum InterfaceType {
	WORLD_LIMITS = 0,
	BACKGROUND_COLOR = 1,
	DECORATION_LIST = 2,
	DECORATION_EDIT = 3,
}

## The root node of each scene is an [AppEditorInterface].
const _INTERFACE_SCENES: Dictionary[InterfaceType, PackedScene] = {
	InterfaceType.WORLD_LIMITS: preload("uid://cyspbdausxgwr"),
	InterfaceType.BACKGROUND_COLOR: preload("uid://bb53mhx3u8ho8"),
	InterfaceType.DECORATION_LIST: preload("uid://bql3bs1c3rgo3"),
	InterfaceType.DECORATION_EDIT: preload("uid://bfpg282qeb0rx"),
}

var _current_interface: Node:
	set(value):
		_current_interface = value
		_update_visibility()

@onready var _contents_container: Node = %Contents


func _ready() -> void:
	_update_visibility()


# TODO bad design: if an interface requires data,
# you shouldn't be able to use this function to open that interface.
## Opens a new interface of given type.
## Please note that some interface types shouldn't be created this way
## because sometimes they require data being passed to them.
func open_new_interface(
		type: InterfaceType,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	open_interface(_new_interface(type, project, editor_settings))


## Opens given interface.
## Closes the already open interface if applicable.
## No effect if the input is null.
func open_interface(new_interface: AppEditorInterface) -> void:
	if new_interface == null:
		return
	close_interface()
	_contents_container.add_child(new_interface)
	_current_interface = new_interface


## Has no effect if there is no interface open.
func close_interface() -> void:
	if _current_interface == null:
		return
	_current_interface.get_parent().remove_child(_current_interface)
	_current_interface.queue_free()
	_current_interface = null


## May return null if the interface scene could not be found.
func _new_interface(
		type: InterfaceType,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> AppEditorInterface:
	if not _INTERFACE_SCENES.has(type):
		push_error("Can't find the scene for this interface type.")
		return null

	var new_interface := (
			_INTERFACE_SCENES[type].instantiate() as AppEditorInterface
	)
	new_interface.editor_settings = editor_settings
	new_interface.game_settings = project.settings

	if new_interface is InterfaceWorldDecoration:
		var decoration_interface := new_interface as InterfaceWorldDecoration
		decoration_interface.decorations = project.game.world.decorations
		decoration_interface.decoration_selected.connect(
				_open_new_decoration_edit_interface.bind(
						project, editor_settings
				)
		)

	return new_interface


func _open_new_decoration_edit_interface(
		world_decoration: WorldDecoration,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	var new_interface := _new_interface(
			InterfaceType.DECORATION_EDIT, project, editor_settings
	) as InterfaceWorldDecorationEdit
	new_interface.back_pressed.connect(open_new_interface.bind(
			InterfaceType.DECORATION_LIST, project, editor_settings
	))
	new_interface.delete_pressed.connect(
			_on_world_decoration_deleted.bind(project, editor_settings)
	)
	new_interface.world_decoration = world_decoration
	open_interface(new_interface)


func _update_visibility() -> void:
	visible = _current_interface != null


func _on_world_decoration_deleted(
		world_decoration: WorldDecoration,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	project.game.world.delete_decoration(world_decoration)
	open_new_interface(InterfaceType.DECORATION_LIST, project, editor_settings)
