class_name GamePlayersFromRaw
## Converts raw data into [GamePlayer] objects.

const PLAYER_ID_KEY: String = "id"
const PLAYER_COUNTRY_ID_KEY: String = "playing_country_id"
const PLAYER_IS_HUMAN_KEY: String = "is_human"
const PLAYER_USERNAME_KEY: String = "username"
const PLAYER_AI_TYPE_KEY: String = "ai_type"
const PLAYER_AI_PERSONALITY_KEY: String = "ai_personality_type"


## Resets given game's [GamePlayers] and adds players to it using given data.
## The game's rules and countries must already be loaded.
##
## This operation always succeeds.
## Players with invalid data are not added.
static func parse_using(raw_data: Variant, game: Game) -> void:
	game.game_players = GamePlayers.new()

	if raw_data is not Array:
		return
	var raw_array: Array = raw_data

	for player_data: Variant in raw_array:
		_parse_player(player_data, game)


## Adds a new player to given game's [GamePlayers] using given data.
## Parsing may fail, in which case there is no effect.
static func _parse_player(raw_data: Variant, game: Game) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	var player := GamePlayer.new()

	# Player id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, PLAYER_ID_KEY):
		return
	var id: int = ParseUtils.dictionary_int(raw_dict, PLAYER_ID_KEY)

	# The player's id must be valid and available.
	if not game.game_players.id_system().is_id_available(id):
		return

	# AI type
	var ai_type: int = 0
	if ParseUtils.dictionary_has_number(raw_dict, PLAYER_AI_TYPE_KEY):
		var loaded_ai_type: int = (
				ParseUtils.dictionary_int(raw_dict, PLAYER_AI_TYPE_KEY)
		)
		if loaded_ai_type in PlayerAI.Type.values():
			ai_type = loaded_ai_type
	player.player_ai = PlayerAI.from_type(ai_type)

	# Playing country
	if ParseUtils.dictionary_has_number(raw_dict, PLAYER_COUNTRY_ID_KEY):
		var country_id: int = (
				ParseUtils.dictionary_int(raw_dict, PLAYER_COUNTRY_ID_KEY)
		)
		if country_id >= 0:
			player.playing_country = game.countries.country_from_id(country_id)

	# Is human
	if ParseUtils.dictionary_has_bool(raw_dict, PLAYER_IS_HUMAN_KEY):
		player.is_human = raw_dict[PLAYER_IS_HUMAN_KEY]

	# Username
	if ParseUtils.dictionary_has_string(raw_dict, PLAYER_USERNAME_KEY):
		player.username = raw_dict[PLAYER_USERNAME_KEY]

	# AI personality type
	var ai_personality_type: int = (
			game.rules.default_ai_personality_option.selected_value()
	)
	if ParseUtils.dictionary_has_number(raw_dict, PLAYER_AI_PERSONALITY_KEY):
		ai_personality_type = (
				ParseUtils.dictionary_int(raw_dict, PLAYER_AI_PERSONALITY_KEY)
		)
	var ai_personality: AIPersonality = (
			AIPersonality.from_type(ai_personality_type)
	)
	if ai_personality != null:
		player.player_ai.personality = ai_personality

	game.game_players.add_player(player, id)
