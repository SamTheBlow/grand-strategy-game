class_name InterfaceProjectInfo
extends AppEditorInterface


func _ready() -> void:
	var item_project_name := ItemString.new()
	item_project_name.text = "Name"
	item_project_name.placeholder_text = project.metadata.DEFAULT_PROJECT_NAME
	item_project_name.value = project.metadata.project_name
	item_project_name.value_changed.connect(_on_item_name_changed)
	project.metadata.name_changed.connect(
			_on_project_name_changed.bind(item_project_name)
	)

	var item_project_icon := ItemTexture.new()
	item_project_icon.text = "Icon"
	item_project_icon.fallback_texture = project.metadata.DEFAULT_PROJECT_ICON
	item_project_icon.popup_requested.connect(
			texture_popup_requested.emit.bind(project.textures)
	)
	item_project_icon.value = project.metadata.icon
	item_project_icon.value_changed.connect(_on_item_icon_changed)
	project.metadata.icon_changed.connect(
			_on_project_icon_changed.bind(item_project_icon).unbind(2)
	)

	var item_game_state := ItemOptions.new()
	item_game_state.text = "Game state"
	item_game_state.options = [ "Setup", "Ongoing", "Game Over" ]
	item_game_state.option_value_map = [
			Game.GameState.SETUP,
			Game.GameState.ONGOING,
			Game.GameState.GAMEOVER,
	]
	item_game_state.selected_index = (
			item_game_state.index_of_value(project.game.state)
	)
	item_game_state.value_changed.connect(_on_item_game_state_changed)
	project.game.state_changed.connect(
			_on_game_state_changed.bind(item_game_state)
	)

	var game_settings := %GameSettingsCategory as ItemVoidNode
	game_settings.item.child_items = [
			item_project_name, item_project_icon, item_game_state
	]
	game_settings.refresh()

	closed.connect(navigator.close_interface)


func _on_item_name_changed(new_value: String) -> void:
	_apply_undo_redo_property(
			"Change project name",
			project.metadata,
			&"project_name",
			project.metadata.project_name,
			new_value
	)


func _on_item_icon_changed(new_value: ProjectTexture) -> void:
	_apply_undo_redo_property(
			"Change project icon",
			project.metadata,
			&"icon",
			project.metadata.icon,
			new_value
	)


func _on_item_game_state_changed(new_value: int) -> void:
	_apply_undo_redo_property(
			"Change game state",
			project.game,
			&"state",
			project.game.state,
			new_value
	)


func _on_project_name_changed(item: ItemString) -> void:
	_set_setting_no_signal(
			item, _on_item_name_changed, project.metadata.project_name
	)


func _on_project_icon_changed(item: ItemTexture) -> void:
	_set_setting_no_signal(item, _on_item_icon_changed, project.metadata.icon)


func _on_game_state_changed(item: ItemOptions) -> void:
	_set_setting_no_signal(
			item,
			_on_item_game_state_changed,
			item.index_of_value(project.game.state)
	)
