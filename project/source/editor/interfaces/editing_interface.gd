class_name EditingInterface
extends Control
## Opens and closes interfaces for the user to use in the editor.

signal texture_popup_requested(
		item_texture: ItemTexture, project_textures: ProjectTextures
)
signal country_select_pressed(item_country: ItemCountry)
signal country_interface_opened(country: Country)
signal country_interface_closed()
signal province_interface_opened(province: Province)
signal province_interface_closed()
signal army_interface_opened(army: Army)
signal army_interface_closed()
signal army_list_item_hovered(army: Army)
signal army_list_item_unhovered()
signal province_list_item_hovered(province: Province)
signal province_list_item_unhovered()
signal decoration_interface_opened(decoration: WorldDecoration)
signal decoration_interface_closed()
signal decoration_list_item_hovered(decoration: WorldDecoration)
signal decoration_list_item_unhovered()

## The root node of each scene is an [AppEditorInterface].
const _INTERFACE_SCENES: Dictionary[InterfaceNavigator.InterfaceType, PackedScene] = {
	InterfaceNavigator.InterfaceType.PROJECT_INFO:
		preload("uid://7k82f8lx1vpe"),
	InterfaceNavigator.InterfaceType.RNG:
		preload("uid://dp53fawdiydun"),
	InterfaceNavigator.InterfaceType.COUNTRY_LIST:
		preload("uid://pns3cw110b6w"),
	InterfaceNavigator.InterfaceType.COUNTRY_RELATIONSHIPS:
		preload("uid://bxnnpjildojmj"),
	InterfaceNavigator.InterfaceType.COUNTRY_NOTIFICATIONS:
		preload("uid://bs0hbgxgmptdv"),
	InterfaceNavigator.InterfaceType.PLAYER_LIST:
		preload("uid://dlpstn5iyda4k"),
	InterfaceNavigator.InterfaceType.TURN_ORDER:
		preload("uid://bgcrykgs0vh3o"),
	InterfaceNavigator.InterfaceType.WORLD_LIMITS:
		preload("uid://cyspbdausxgwr"),
	InterfaceNavigator.InterfaceType.BACKGROUND_COLOR:
		preload("uid://bb53mhx3u8ho8"),
	InterfaceNavigator.InterfaceType.DECORATION_LIST:
		preload("uid://bql3bs1c3rgo3"),
	InterfaceNavigator.InterfaceType.PROVINCE_LIST:
		preload("uid://bluif37tipwg7"),
	InterfaceNavigator.InterfaceType.ARMY_LIST:
		preload("uid://l2nhdgg0p4oo"),
}

const _PROVINCE_EDIT_SCENE: PackedScene = preload("uid://bafpj3jqosje7")
const _ARMY_EDIT_SCENE: PackedScene = preload("uid://n04sb8kke04h")
const _DECORATION_EDIT_SCENE: PackedScene = preload("uid://bfpg282qeb0rx")
const _COUNTRY_EDIT_SCENE: PackedScene = preload("uid://ck6hme0uj2nuu")
const _PLAYER_EDIT_SCENE: PackedScene = preload("uid://exhe7mpnu7w1")
const _RELATIONSHIPS_EDIT_SCENE: PackedScene = preload("uid://bxnnpjildojmj")
const _NOTIFICATIONS_EDIT_SCENE: PackedScene = preload("uid://bs0hbgxgmptdv")

var _navigator := InterfaceNavigator.new(self)
var _undo_redo: UndoRedo

var _current_interface: AppEditorInterface:
	set(value):
		if _current_interface == value:
			return

		if _current_interface != null:
			# Use queue_free() instead of immediately deleting the node
			# so that input events still propagate through it on this frame.
			_current_interface.queue_free()

		if _current_interface is InterfaceProvinceEdit:
			_current_interface = null
			province_interface_closed.emit()
		elif _current_interface is InterfaceCountryEdit:
			_current_interface = null
			country_interface_closed.emit()
		elif _current_interface is InterfaceArmyEdit:
			_current_interface = null
			army_interface_closed.emit()
		elif _current_interface is InterfaceWorldDecorationEdit:
			_current_interface = null
			decoration_interface_closed.emit()

		_current_interface = value

		if is_node_ready():
			_update_contents()

@onready var _contents_container: Node = %Contents


func _ready() -> void:
	_update_contents()


## Opens a new interface of given type.
func open_new_interface(
		type: InterfaceNavigator.InterfaceType,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	var new_interface := _new_interface_of_type(type)
	if new_interface != null:
		_open_interface(new_interface, project, editor_settings)


## Has no effect if there is no interface open.
func close_interface() -> void:
	_current_interface = null


## Opens the interface for editing given province.
func open_province_edit_interface(
		province_id: int,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	# Prevent infinite loop
	if (
			_current_interface is InterfaceProvinceEdit
			and province_id
			== (_current_interface as InterfaceProvinceEdit).province.id
	):
		return

	var province: Province = (
			project.game.world.provinces.province_from_id(province_id)
	)
	if province == null:
		push_error("Province doesn't exist.")
		return

	var new_interface := (
			_PROVINCE_EDIT_SCENE.instantiate() as InterfaceProvinceEdit
	)
	new_interface.province = province
	_open_interface(new_interface, project, editor_settings)
	province_interface_opened.emit(province)


## Opens the interface for editing given army.
func open_army_edit_interface(
		army: Army, project: GameProject, editor_settings: AppEditorSettings
) -> void:
	# Prevent infinite loop
	if (
			_current_interface is InterfaceArmyEdit
			and army == (_current_interface as InterfaceArmyEdit).army
	):
		return

	var new_interface := _ARMY_EDIT_SCENE.instantiate() as InterfaceArmyEdit
	new_interface.army = army
	_open_interface(new_interface, project, editor_settings)
	army_interface_opened.emit(army)


## Opens the interface for editing given world decoration.
func open_decoration_edit_interface(
		world_decoration: WorldDecoration,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	# Prevent infinite loop
	if (
			_current_interface is InterfaceWorldDecorationEdit
			and world_decoration == (
					_current_interface as InterfaceWorldDecorationEdit
			).world_decoration
	):
		return

	var new_interface := (
			_DECORATION_EDIT_SCENE.instantiate()
			as InterfaceWorldDecorationEdit
	)
	new_interface.world_decoration = world_decoration
	_open_interface(new_interface, project, editor_settings)
	decoration_interface_opened.emit(world_decoration)


## Opens the interface for editing given country.
func open_country_edit_interface(
		country_id: int,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	var country: Country = project.game.countries.country_from_id(country_id)
	if country == null:
		push_error("Country doesn't exist.")
		return

	var new_interface := (
			_COUNTRY_EDIT_SCENE.instantiate() as InterfaceCountryEdit
	)
	new_interface.country = country
	_open_interface(new_interface, project, editor_settings)
	country_interface_opened.emit(country)


## Opens the interface for editing given player.
func open_player_edit_interface(
		player_id: int,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	var game_player: GamePlayer = (
			project.game.game_players.player_from_id(player_id)
	)
	if game_player == null:
		push_error("Player doesn't exist.")
		return

	var new_interface := (
			_PLAYER_EDIT_SCENE.instantiate() as InterfacePlayerEdit
	)
	new_interface.game_player = game_player
	_open_interface(new_interface, project, editor_settings)


## Opens the interface for editing given country's relationships.
func open_country_relationships_interface(
		country: Country,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	var new_interface := (
			_RELATIONSHIPS_EDIT_SCENE.instantiate()
			as InterfaceCountryRelationships
	)
	new_interface.country = country
	_open_interface(new_interface, project, editor_settings)


## Opens the interface for editing given country's notifications.
func open_country_notifications_interface(
		country: Country,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	var new_interface := (
			_NOTIFICATIONS_EDIT_SCENE.instantiate()
			as InterfaceCountryNotifications
	)
	new_interface.country = country
	_open_interface(new_interface, project, editor_settings)


func _update_contents() -> void:
	visible = _current_interface != null
	if _current_interface != null:
		_current_interface.undo_redo = _undo_redo
		_forward_interface_signals(_current_interface)
		_contents_container.add_child(_current_interface)


## Prepares the interface and then opens it.
func _open_interface(
		new_interface: AppEditorInterface,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	new_interface.project = project
	new_interface.editor_settings = editor_settings
	new_interface.navigator = _navigator
	new_interface.undo_redo = _undo_redo
	_current_interface = new_interface


## May return null if the interface scene could not be found.
func _new_interface_of_type(
		type: InterfaceNavigator.InterfaceType
) -> AppEditorInterface:
	if not _INTERFACE_SCENES.has(type):
		push_error("Can't find the scene for this interface type.")
		return null
	return _INTERFACE_SCENES[type].instantiate() as AppEditorInterface


## Propagates up the current interface's signals.
func _forward_interface_signals(interface: AppEditorInterface) -> void:
	interface.texture_popup_requested.connect(texture_popup_requested.emit)
	interface.country_select_pressed.connect(country_select_pressed.emit)
	interface.army_list_item_hovered.connect(army_list_item_hovered.emit)
	interface.army_list_item_unhovered.connect(army_list_item_unhovered.emit)
	interface.province_list_item_hovered.connect(province_list_item_hovered.emit)
	interface.province_list_item_unhovered.connect(province_list_item_unhovered.emit)
	interface.decoration_list_item_hovered.connect(decoration_list_item_hovered.emit)
	interface.decoration_list_item_unhovered.connect(decoration_list_item_unhovered.emit)


func _on_history_initialized(undo_redo: UndoRedo) -> void:
	_undo_redo = undo_redo
