class_name InterfacePlayerEdit
extends AppEditorInterface
## Interface for editing given [GamePlayer].

var game_player := GamePlayer.new()


func _ready() -> void:
	_setup_settings(%Settings as ItemVoidNode)

	closed.connect(navigator.open_new_interface.bind(
			InterfaceNavigator.Type.PLAYER_LIST, project, editor_settings
	))


func _load_settings(settings_item: PropertyTreeItem) -> void:
	# Username
	var item_username := settings_item.child_items[0] as ItemString
	item_username.placeholder_text = game_player.username_or_default()
	item_username.value = game_player.username
	item_username.value_changed.connect(_on_item_username_changed)
	game_player.username_changed.connect(
			_on_player_username_changed.bind(item_username).unbind(1)
	)

	# Country
	var item_country := settings_item.child_items[1] as ItemCountry
	item_country.value = game_player.playing_country
	item_country.value_changed.connect(_on_item_country_changed)
	item_country.change_requested.connect(country_select_pressed.emit)
	game_player.playing_country_changed.connect(
			_on_player_country_changed.bind(item_country, item_username)
	)

	# Is human
	var item_is_human := settings_item.child_items[2] as ItemBool
	item_is_human.value = game_player.is_human
	item_is_human.value_changed.connect(_on_item_is_human_changed)
	game_player.human_status_changed.connect(
			_on_player_is_human_changed.bind(item_is_human).unbind(1)
	)

	# AI type
	var item_ai_type := settings_item.child_items[3] as ItemOptions
	item_ai_type.selected_index = (
			item_ai_type.index_of_value(game_player.player_ai.type())
	)
	item_ai_type.value_changed.connect(_on_item_ai_type_changed)

	# AI personality
	var item_ai_personality := settings_item.child_items[4] as ItemOptions
	item_ai_personality.selected_index = item_ai_personality.index_of_value(
			game_player.player_ai.personality.type()
	)
	item_ai_personality.value_changed.connect(
			_on_item_ai_personality_changed
	)
	game_player.player_ai.personality_changed.connect(
			_on_personality_changed.bind(item_ai_personality)
	)
	game_player.ai_changed.connect(
			_on_player_ai_changed.bind(item_ai_type, item_ai_personality)
	)


func _delete() -> void:
	project.game.game_players.undo_redo_remove(game_player, undo_redo)


func _duplicate() -> void:
	# Create duplicate
	var new_player := GamePlayer.new()
	new_player.username = game_player.username
	new_player.playing_country = game_player.playing_country
	new_player.is_human = game_player.is_human
	new_player.player_ai = PlayerAI.from_type(game_player.player_ai.type())
	new_player.player_ai.personality = (
			AIPersonality.from_type(game_player.player_ai.personality.type())
	)

	# We need this new player to have a new unique id
	# assigned to it before we can create the undo_redo action
	var game_players: GamePlayers = project.game.game_players
	game_players.add(new_player)

	# Create undo_redo action
	# (don't execute it since we already added the player)
	undo_redo.create_action("Duplicate player")
	undo_redo.add_do_method(game_players.add.bind(new_player))
	undo_redo.add_undo_method(game_players.remove.bind(new_player))
	undo_redo.commit_action(false)

	navigator.open_player_edit_interface(new_player, project, editor_settings)


func _on_player_removed(player_removed: GamePlayer) -> void:
	if player_removed == game_player:
		closed.emit()


func _on_item_username_changed(item: ItemString) -> void:
	_apply_undo_redo_property(
			"Change player username",
			game_player,
			&"username",
			game_player.username,
			item.value
	)


func _on_item_country_changed(item: ItemCountry) -> void:
	_apply_undo_redo_property(
			"Change player's country",
			game_player,
			&"playing_country",
			game_player.playing_country,
			item.value
	)


func _on_item_is_human_changed(item: ItemBool) -> void:
	_apply_undo_redo_property(
			"Toggle whether or not player is human",
			game_player,
			&"is_human",
			game_player.is_human,
			item.value
	)


func _on_item_ai_type_changed(item: ItemOptions) -> void:
	var new_ai: PlayerAI = PlayerAI.from_type(item.selected_value())
	if new_ai == null:
		return

	var old_ai: PlayerAI = game_player.player_ai
	new_ai.personality = old_ai.personality

	_apply_undo_redo_property(
			"Change AI type", game_player, &"player_ai", old_ai, new_ai
	)


func _on_item_ai_personality_changed(item: ItemOptions) -> void:
	var new_personality: AIPersonality = (
			AIPersonality.from_type(item.selected_value())
	)
	if new_personality == null:
		return

	_apply_undo_redo_property(
			"Change AI personality",
			game_player.player_ai,
			&"personality",
			game_player.player_ai.personality,
			new_personality
	)


func _on_player_username_changed(item: ItemString) -> void:
	_set_setting_no_signal(
			item, _on_item_username_changed, game_player.username
	)


func _on_player_country_changed(
		item_country: ItemCountry, item_username: ItemString
) -> void:
	_set_setting_no_signal(
			item_country, _on_item_country_changed, game_player.playing_country
	)

	# The playing country can affect the default username
	item_username.placeholder_text = game_player.username_or_default()


func _on_player_is_human_changed(item: ItemBool) -> void:
	_set_setting_no_signal(
			item, _on_item_is_human_changed, game_player.is_human
	)


func _on_player_ai_changed(
		old_ai: PlayerAI,
		new_ai: PlayerAI,
		item_ai_type: ItemOptions,
		item_ai_personality: ItemOptions
) -> void:
	_set_setting_no_signal(
			item_ai_type,
			_on_item_ai_type_changed,
			item_ai_type.index_of_value(new_ai.type())
	)

	old_ai.personality_changed.disconnect(_on_personality_changed)
	new_ai.personality_changed.connect(
			_on_personality_changed.bind(item_ai_personality)
	)


func _on_personality_changed(item: ItemOptions) -> void:
	_set_setting_no_signal(
			item,
			_on_item_ai_personality_changed,
			item.index_of_value(game_player.player_ai.personality.type())
	)
