class_name InterfaceNavigator
## Provides methods for opening or closing an editor interface.

## The type of interface to open.
enum Type {
	PROJECT_INFO,
	RNG,
	COUNTRY_LIST,
	COUNTRY_EDIT,
	COUNTRY_RELATIONSHIPS,
	COUNTRY_NOTIFICATIONS,
	PLAYER_LIST,
	PLAYER_EDIT,
	TURN_ORDER,
	WORLD_LIMITS,
	BACKGROUND_COLOR,
	DECORATION_LIST,
	DECORATION_EDIT,
	PROVINCE_LIST,
	PROVINCE_EDIT,
	ARMY_LIST,
	ARMY_EDIT,
}

var _editor: EditingInterface


func _init(editor: EditingInterface) -> void:
	_editor = editor


## Opens a new interface of given type.
func open_new_interface(
		type: Type, project: GameProject, editor_settings: AppEditorSettings
) -> void:
	_editor.open_new_interface(type, project, editor_settings)


## Closes the currently open interface, if any.
func close_interface() -> void:
	_editor.close_interface()


## Opens the interface for editing given country.
func open_country_edit_interface(
		country: Country,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	_editor.open_country_edit_interface(country, project, editor_settings)


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


## Opens the interface for editing given player.
func open_player_edit_interface(
		player: GamePlayer,
		project: GameProject,
		editor_settings: AppEditorSettings
) -> void:
	_editor.open_player_edit_interface(player, project, editor_settings)
