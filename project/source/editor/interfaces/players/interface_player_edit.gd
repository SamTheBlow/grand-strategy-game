class_name InterfacePlayerEdit
extends AppEditorInterface
## Interface for editing given [GamePlayer].

signal closed()
signal delete_pressed(game_player: GamePlayer)
signal duplicate_pressed(game_player: GamePlayer)
signal country_select_pressed(item_country: ItemCountry)

var game_player := GamePlayer.new()

## This interface automatically closes
## if its player is removed from this players list.
## May be null, in which case this feature is not used.
var game_players: GamePlayers = null:
	set(value):
		if game_players != null:
			game_players.player_removed.disconnect(_on_player_removed)

		game_players = value

		if game_players != null:
			game_players.player_removed.connect(_on_player_removed)

@onready var _settings := %Settings as ItemVoidNode


func _ready() -> void:
	# Create a deep copy of the settings resource,
	# to avoid sharing it with another interface
	_settings.item = _settings.item.duplicate_deep() as PropertyTreeItem
	_settings.refresh()

	_load_settings()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"delete"):
		delete_pressed.emit(game_player)
	if Input.is_action_just_pressed(&"duplicate"):
		duplicate_pressed.emit(game_player)


func _setting_username() -> ItemString:
	return _settings.item.child_items[0] as ItemString


func _setting_country() -> ItemCountry:
	return _settings.item.child_items[1] as ItemCountry


func _setting_is_human() -> ItemBool:
	return _settings.item.child_items[2] as ItemBool


func _setting_ai_type() -> ItemOptions:
	return _settings.item.child_items[3] as ItemOptions


func _setting_ai_personality() -> ItemOptions:
	return _settings.item.child_items[4] as ItemOptions


func _load_settings() -> void:
	# Username
	_setting_username().placeholder_text = game_player.username_or_default()
	_setting_username().value = game_player.username
	_setting_username().value_changed.connect(_on_item_username_changed)
	game_player.username_changed.connect(_on_player_username_changed)

	# Country
	_setting_country().value = game_player.playing_country
	_setting_country().value_changed.connect(_on_item_country_changed)
	_setting_country().change_requested.connect(country_select_pressed.emit)
	game_player.playing_country_changed.connect(_on_player_country_changed)

	# Is human
	_setting_is_human().value = game_player.is_human
	_setting_is_human().value_changed.connect(_on_item_is_human_changed)
	game_player.human_status_changed.connect(_on_player_is_human_changed)

	# AI type
	_setting_ai_type().selected_index = (
			_setting_ai_type().index_of_value(game_player.player_ai.type())
	)
	_setting_ai_type().value_changed.connect(_on_item_ai_type_changed)
	game_player.ai_changed.connect(_on_player_ai_changed)

	# AI personality
	_setting_ai_personality().selected_index = (
			_setting_ai_personality().index_of_value(
					game_player.player_ai.personality.type()
			)
	)
	_setting_ai_personality().value_changed.connect(
			_on_item_ai_personality_changed
	)
	game_player.player_ai.personality_changed.connect(_on_personality_changed)


func _apply_undo_redo_action(
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


func _on_back_button_pressed() -> void:
	closed.emit()


func _on_player_removed(player_removed: GamePlayer) -> void:
	if player_removed == game_player:
		closed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(game_player)


func _on_item_username_changed(_item: PropertyTreeItem) -> void:
	_apply_undo_redo_action(
			"Change player username",
			game_player,
			&"username",
			game_player.username,
			_setting_username().value
	)


func _on_item_country_changed(_item: PropertyTreeItem) -> void:
	_apply_undo_redo_action(
			"Change player's country",
			game_player,
			&"playing_country",
			game_player.playing_country,
			_setting_country().value
	)


func _on_item_is_human_changed(_item: PropertyTreeItem) -> void:
	_apply_undo_redo_action(
			"Toggle whether or not player is human",
			game_player,
			&"is_human",
			game_player.is_human,
			_setting_is_human().value
	)


func _on_item_ai_type_changed(_item: PropertyTreeItem) -> void:
	var new_value: int = _setting_ai_type().selected_value()
	var new_ai: PlayerAI = PlayerAI.from_type(new_value)
	if new_ai == null:
		return

	var old_ai: PlayerAI = game_player.player_ai
	new_ai.personality = old_ai.personality

	# Create undo/redo action
	undo_redo.create_action("Change AI type")
	undo_redo.add_do_property(game_player, &"player_ai", new_ai)
	undo_redo.add_undo_property(game_player, &"player_ai", old_ai)
	undo_redo.commit_action()


func _on_item_ai_personality_changed(_item: PropertyTreeItem) -> void:
	var new_value: int = _setting_ai_personality().selected_value()
	var new_personality: AIPersonality = AIPersonality.from_type(new_value)
	if new_personality == null:
		return

	var old_personality: AIPersonality = game_player.player_ai.personality

	# Create undo/redo action
	undo_redo.create_action("Change AI personality")
	undo_redo.add_do_property(
			game_player.player_ai, &"personality", new_personality
	)
	undo_redo.add_undo_property(
			game_player.player_ai, &"personality", old_personality
	)
	undo_redo.commit_action()


func _on_player_username_changed(_game_player: GamePlayer = null) -> void:
	_setting_username().value_changed.disconnect(_on_item_username_changed)
	_setting_username().value = game_player.username
	_setting_username().value_changed.connect(_on_item_username_changed)


func _on_player_country_changed() -> void:
	_setting_country().value_changed.disconnect(_on_item_country_changed)
	_setting_country().value = game_player.playing_country
	_setting_country().value_changed.connect(_on_item_country_changed)

	# The playing country can affect the default username
	_setting_username().placeholder_text = game_player.username_or_default()


func _on_player_is_human_changed(_game_player: GamePlayer) -> void:
	_setting_is_human().value_changed.disconnect(_on_item_is_human_changed)
	_setting_is_human().value = game_player.is_human
	_setting_is_human().value_changed.connect(_on_item_is_human_changed)


func _on_player_ai_changed(old_ai: PlayerAI, new_ai: PlayerAI) -> void:
	_setting_ai_type().value_changed.disconnect(_on_item_ai_type_changed)
	_setting_ai_type().selected_index = (
			_setting_ai_type().index_of_value(new_ai.type())
	)
	_setting_ai_type().value_changed.connect(_on_item_ai_type_changed)

	old_ai.personality_changed.disconnect(_on_personality_changed)
	new_ai.personality_changed.connect(_on_personality_changed)


func _on_personality_changed() -> void:
	_setting_ai_personality().value_changed.disconnect(
			_on_item_ai_personality_changed
	)
	_setting_ai_personality().selected_index = (
			_setting_ai_personality().index_of_value(
					game_player.player_ai.personality.type()
			)
	)
	_setting_ai_personality().value_changed.connect(
			_on_item_ai_personality_changed
	)
