class_name InterfaceNavigator
## Provides methods for opening or closing an editor interface.

## The type of interface to open.
enum InterfaceType {
	PROJECT_INFO,
	RNG,
	COUNTRY_LIST,
	COUNTRY_RELATIONSHIPS,
	COUNTRY_NOTIFICATIONS,
	PLAYER_LIST,
	TURN_ORDER,
	WORLD_LIMITS,
	BACKGROUND_COLOR,
	DECORATION_LIST,
	PROVINCE_LIST,
	ARMY_LIST,
}

var _editor: EditingInterface


func _init(editor: EditingInterface) -> void:
	_editor = editor


## Opens a new interface of given type.
func open_new_interface(
		type: InterfaceType,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	_editor.open_new_interface(type, project, editor_settings)


## Closes the currently open interface, if any.
func close_interface() -> void:
	_editor.close_interface()


## Opens the interface for editing given country.
func open_country_edit_interface(
		country_id: int,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	_editor.open_country_edit_interface(country_id, project, editor_settings)


## Opens the interface for editing given player.
func open_player_edit_interface(
		player_id: int,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	_editor.open_player_edit_interface(player_id, project, editor_settings)


## Opens the interface for editing given province.
func open_province_edit_interface(
		province_id: int,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	_editor.open_province_edit_interface(province_id, project, editor_settings)


## Opens the interface for editing given army.
func open_army_edit_interface(
		army: Army,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	_editor.open_army_edit_interface(army, project, editor_settings)


## Opens the interface for editing given world decoration.
func open_decoration_edit_interface(
		world_decoration: WorldDecoration,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	_editor.open_decoration_edit_interface(
			world_decoration, project, editor_settings
	)


## Opens the interface for editing given country's relationships.
func open_country_relationships_interface(
		country: Country,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	_editor.open_country_relationships_interface(
			country, project, editor_settings
	)


## Opens the interface for editing given country's notifications.
func open_country_notifications_interface(
		country: Country,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	_editor.open_country_notifications_interface(
			country, project, editor_settings
	)
