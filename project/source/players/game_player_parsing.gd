class_name GamePlayerParsing
## Parses raw data from/to [GamePlayer] instances.

const _ID_KEY: String = "id"
const _COUNTRY_ID_KEY: String = "playing_country_id"
const _IS_HUMAN_KEY: String = "is_human"
const _USERNAME_KEY: String = "username"
const _AI_TYPE_KEY: String = "ai_type"
const _AI_PERSONALITY_KEY: String = "ai_personality_type"


## NOTE: Given game's rules and countries must already be loaded.
##
## Resets given game's [GamePlayers] and adds players to it using given data.
##
## Always succeeds. Ignores unrecognized data.
## Players with invalid data are not added.
static func load_from_raw_data(raw_data: Variant, game: Game) -> void:
	game.game_players = GamePlayers.new()

	if raw_data is not Array:
		return
	var raw_array: Array = raw_data

	for player_data: Variant in raw_array:
		_load_player_from_raw(player_data, game)


static func to_raw_array(game_players: GamePlayers) -> Array:
	var output: Array = []

	for player in game_players._list:
		output.append(_player_to_raw_dict(player))

	return output


## Adds a new player to given game's [GamePlayers] using given data.
## Parsing may fail, in which case there is no effect.
static func _load_player_from_raw(raw_data: Variant, game: Game) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Player id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, _ID_KEY):
		return
	var id: int = ParseUtils.dictionary_int(raw_dict, _ID_KEY)

	# The player's id must be valid and available.
	if not game.game_players.id_system().is_id_available(id):
		return

	var player := GamePlayer.new()

	# AI type
	# 4.0 Backwards compatibility:
	# When the save data doesn't contain the AI type,
	# it must be assumed to be 0.
	var ai_type: int = 0
	if ParseUtils.dictionary_has_number(raw_dict, _AI_TYPE_KEY):
		var loaded_ai_type: int = (
				ParseUtils.dictionary_int(raw_dict, _AI_TYPE_KEY)
		)
		if loaded_ai_type in PlayerAI.Type.values():
			ai_type = loaded_ai_type
	player.player_ai = PlayerAI.from_type(ai_type)

	# Playing country
	if ParseUtils.dictionary_has_number(raw_dict, _COUNTRY_ID_KEY):
		var country_id: int = (
				ParseUtils.dictionary_int(raw_dict, _COUNTRY_ID_KEY)
		)
		if country_id >= 0:
			player.playing_country = game.countries.country_from_id(country_id)

	# Is human
	if ParseUtils.dictionary_has_bool(raw_dict, _IS_HUMAN_KEY):
		player.is_human = raw_dict[_IS_HUMAN_KEY]

	# Username
	if ParseUtils.dictionary_has_string(raw_dict, _USERNAME_KEY):
		player.username = raw_dict[_USERNAME_KEY]

	# AI personality type
	var ai_personality_type: int = (
			game.rules.default_ai_personality_option.selected_value()
	)
	if ParseUtils.dictionary_has_number(raw_dict, _AI_PERSONALITY_KEY):
		ai_personality_type = (
				ParseUtils.dictionary_int(raw_dict, _AI_PERSONALITY_KEY)
		)
	var ai_personality: AIPersonality = (
			AIPersonality.from_type(ai_personality_type)
	)
	if ai_personality != null:
		player.player_ai.personality = ai_personality

	game.game_players.add_player(player, id)


static func _player_to_raw_dict(player: GamePlayer) -> Dictionary:
	var output: Dictionary = {
		_ID_KEY: player.id,
		_IS_HUMAN_KEY: player.is_human,
		_USERNAME_KEY: player.username,
		_AI_TYPE_KEY: player.player_ai.type(),
		_AI_PERSONALITY_KEY: player.player_ai.personality.type(),
	}

	if player.playing_country != null:
		output.merge({ _COUNTRY_ID_KEY: player.playing_country.id })

	return output
