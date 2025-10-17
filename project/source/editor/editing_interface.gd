class_name EditingInterface
extends Control
## Hides itself when the interface is closed,
## shows itself when the interface is open.

signal province_interface_opened(province: Province)
signal province_interface_closed()

enum InterfaceType {
	WORLD_LIMITS = 0,
	BACKGROUND_COLOR = 1,
	DECORATION_LIST = 2,
	PROVINCE_LIST = 3,
}

## The root node of each scene is an [AppEditorInterface].
const _INTERFACE_SCENES: Dictionary[InterfaceType, PackedScene] = {
	InterfaceType.WORLD_LIMITS: preload("uid://cyspbdausxgwr"),
	InterfaceType.BACKGROUND_COLOR: preload("uid://bb53mhx3u8ho8"),
	InterfaceType.DECORATION_LIST: preload("uid://bql3bs1c3rgo3"),
	InterfaceType.PROVINCE_LIST: preload("uid://bluif37tipwg7"),
}

var _current_interface: Node:
	set(value):
		_current_interface = value
		_update_visibility()

@onready var _contents_container: Node = %Contents


func _ready() -> void:
	_update_visibility()


## Opens a new interface of given type.
func open_new_interface(
		type: InterfaceType,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	open_interface(_new_interface_of_type(type, project, editor_settings))


## Opens given interface.
## Closes the already open interface if applicable.
## No effect if the input is null.
func open_interface(new_interface: AppEditorInterface) -> void:
	if new_interface == null:
		return
	_remove_existing_interface()
	_contents_container.add_child(new_interface)
	_current_interface = new_interface


## Has no effect if there is no interface open.
func close_interface() -> void:
	if _current_interface == null:
		return
	elif _current_interface is InterfaceProvinceEdit:
		_remove_existing_interface()
		province_interface_closed.emit()
	else:
		_remove_existing_interface()


func _remove_existing_interface() -> void:
	if _current_interface == null:
		return
	_current_interface.get_parent().remove_child(_current_interface)
	_current_interface.queue_free()
	_current_interface = null


## May return null if the interface scene could not be found.
func _new_interface_of_type(
		type: InterfaceType,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> AppEditorInterface:
	if not _INTERFACE_SCENES.has(type):
		push_error("Can't find the scene for this interface type.")
		return null
	return _new_interface(_INTERFACE_SCENES[type], project, editor_settings)


func _new_interface(
		interface_scene: PackedScene,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> AppEditorInterface:
	var new_interface := interface_scene.instantiate() as AppEditorInterface
	new_interface.editor_settings = editor_settings
	new_interface.game_settings = project.settings

	if new_interface is InterfaceDecorationList:
		var list_interface := new_interface as InterfaceDecorationList
		list_interface.decorations = project.game.world.decorations
		list_interface.item_selected.connect(
				_open_new_decoration_edit_interface.bind(
						project, editor_settings
				)
		)
	elif new_interface is InterfaceProvinceList:
		var list_interface := new_interface as InterfaceProvinceList
		list_interface.provinces = project.game.world.provinces
		list_interface.item_selected.connect(
				open_province_edit_interface.bind(project, editor_settings)
		)

	return new_interface


func _open_new_decoration_edit_interface(
		world_decoration: WorldDecoration,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	var new_interface := _new_interface(
			preload("uid://bfpg282qeb0rx"), project, editor_settings
	) as InterfaceWorldDecorationEdit
	new_interface.back_pressed.connect(open_new_interface.bind(
			InterfaceType.DECORATION_LIST, project, editor_settings
	))
	new_interface.delete_pressed.connect(
			_on_world_decoration_deleted.bind(project, editor_settings)
	)
	new_interface.duplicate_pressed.connect(
			_on_world_decoration_duplicated.bind(project, editor_settings)
	)
	new_interface.world_decoration = world_decoration
	open_interface(new_interface)


## Opens the interface for editing given [Province].
func open_province_edit_interface(
		province: Province,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	if province == null:
		return

	var new_interface := _new_interface(
			preload("uid://bafpj3jqosje7"), project, editor_settings
	) as InterfaceProvinceEdit
	new_interface.back_pressed.connect(open_new_interface.bind(
			InterfaceType.PROVINCE_LIST, project, editor_settings
	))
	#new_interface.delete_pressed.connect(
	#		_on_province_deleted.bind(project, editor_settings)
	#)
	#new_interface.duplicate_pressed.connect(
	#		_on_province_duplicated.bind(project, editor_settings)
	#)
	new_interface.province = province
	open_interface(new_interface)
	province_interface_opened.emit(province)


func _update_visibility() -> void:
	visible = _current_interface != null


func _on_world_decoration_deleted(
		world_decoration: WorldDecoration,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	project.game.world.decorations.remove(world_decoration)
	open_new_interface(InterfaceType.DECORATION_LIST, project, editor_settings)


func _on_world_decoration_duplicated(
		world_decoration: WorldDecoration,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	const _DUPLICATE_DECORATION_OFFSET = Vector2(64.0, 64.0)

	var new_decoration := WorldDecoration.new()
	new_decoration.texture = world_decoration.texture
	new_decoration.flip_h = world_decoration.flip_h
	new_decoration.flip_v = world_decoration.flip_v
	new_decoration.position = (
			world_decoration.position + _DUPLICATE_DECORATION_OFFSET
	)
	new_decoration.rotation_degrees = world_decoration.rotation_degrees
	new_decoration.scale = world_decoration.scale
	new_decoration.color = world_decoration.color

	project.game.world.decorations.add(new_decoration)
	_open_new_decoration_edit_interface(
			new_decoration, project, editor_settings
	)
