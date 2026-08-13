class_name PlayerCreation
extends GameComponent
## Adds new players to the game to ensure all countries have an AI.

const ID: int = 3

const _DEFAULT_AI_TYPE_KEY: String = "default_ai_type"
const _DEFAULT_AI_PERSONALITY_KEY: String = "default_ai_personality"

var _default_ai_type: int = PlayerAI.Type.NONE
var _default_ai_personality: int = AIPersonality.Type.NONE


func _init() -> void:
	priority_index = 20


func id() -> int:
	return ID


func run(game: Game) -> void:
	# Find which countries don't have a player assigned
	var unassigned_countries: Array[Country] = game.countries.list()
	for game_player in game.game_players.list():
		unassigned_countries.erase(game_player.playing_country)

	# Create a new player for each unassigned country
	for country in unassigned_countries:
		var new_player := GamePlayer.new()
		new_player.playing_country = country
		new_player.player_ai = PlayerAI.from_type(_default_ai_type)
		new_player.player_ai.personality = (
				AIPersonality.from_type(_default_ai_personality)
		)
		game.game_players.add(new_player)


func to_raw_data() -> Dictionary:
	var output: Dictionary = { _ID_KEY: ID }
	if _default_ai_type != PlayerAI.Type.NONE:
		output[_DEFAULT_AI_TYPE_KEY] = _default_ai_type
	if _default_ai_personality != AIPersonality.Type.NONE:
		output[_DEFAULT_AI_PERSONALITY_KEY] = _default_ai_personality
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	# AI Type
	if ParseUtils.dictionary_has_number(raw_dict, _DEFAULT_AI_TYPE_KEY):
		_default_ai_type = (
				ParseUtils.dictionary_int(raw_dict, _DEFAULT_AI_TYPE_KEY)
		)
		if _default_ai_type not in PlayerAI.Type.values():
			_default_ai_type = PlayerAI.Type.NONE
	else:
		_default_ai_type = PlayerAI.Type.NONE

	# AI Personality
	if ParseUtils.dictionary_has_number(raw_dict, _DEFAULT_AI_PERSONALITY_KEY):
		_default_ai_personality = (
				ParseUtils.dictionary_int(raw_dict, _DEFAULT_AI_PERSONALITY_KEY)
		)
		if _default_ai_personality not in AIPersonality.Type.values():
			_default_ai_personality = AIPersonality.Type.NONE
	else:
		_default_ai_personality = AIPersonality.Type.NONE
