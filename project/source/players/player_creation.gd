class_name PlayerCreation
extends GameComponent
## During game setup, creates a new AI player for each country without one.

const KEY: String = "player_creation"
const TITLE: String = "Player Creation"
const DESCRIPTION: String = "During game setup, creates a new AI player for each country without one."
const SETTINGS: Array = [
	{ "property_name": _DEFAULT_AI_TYPE_KEY, "text": "Default AI type", "type": "options", "options": [ "Random", "None", "Test AI 1", "Test AI 2" ], "option_map": [ -1, 0, 1, 2 ] },
	{ "property_name": _DEFAULT_AI_PERSONALITY_KEY, "text": "Default AI personality", "type": "options", "options": [ "Random", "None", "Interventionist", "Isolationist", "Shy", "Greedy", "Emotional", "Erratic", "Accepts Everything" ], "option_map": [ -1, 0, 1, 2, 3, 4, 5, 6, 7 ] },
]

const _DEFAULT_AI_TYPE_KEY: String = "default_ai_type"
const _DEFAULT_AI_PERSONALITY_KEY: String = "default_ai_personality"

var default_ai_type: int = PlayerAI.Type.NONE
var default_ai_personality: int = AIPersonality.Type.NONE


func _init() -> void:
	priority_index = 20


## Registers this component to run at the end of the setup phase.
func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	# Find which countries don't have a player assigned
	var unassigned_countries: Array[Country] = game.countries.list()
	for game_player in game.game_players.list():
		unassigned_countries.erase(game_player.playing_country)

	# Create a new player for each unassigned country
	for country in unassigned_countries:
		var new_player := GamePlayer.new()
		new_player.playing_country = country
		new_player.player_ai = PlayerAI.from_type(default_ai_type)
		new_player.player_ai.personality = (
				AIPersonality.from_type(default_ai_personality)
		)
		game.game_players.add(new_player)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if default_ai_type != PlayerAI.Type.NONE:
		output[_DEFAULT_AI_TYPE_KEY] = default_ai_type
	if default_ai_personality != AIPersonality.Type.NONE:
		output[_DEFAULT_AI_PERSONALITY_KEY] = default_ai_personality
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	# AI Type
	if ParseUtils.dictionary_has_number(raw_dict, _DEFAULT_AI_TYPE_KEY):
		default_ai_type = (
				ParseUtils.dictionary_int(raw_dict, _DEFAULT_AI_TYPE_KEY)
		)
		if default_ai_type not in PlayerAI.Type.values():
			default_ai_type = PlayerAI.Type.NONE
	else:
		default_ai_type = PlayerAI.Type.NONE

	# AI Personality
	if ParseUtils.dictionary_has_number(raw_dict, _DEFAULT_AI_PERSONALITY_KEY):
		default_ai_personality = (
				ParseUtils.dictionary_int(raw_dict, _DEFAULT_AI_PERSONALITY_KEY)
		)
		if default_ai_personality not in AIPersonality.Type.values():
			default_ai_personality = AIPersonality.Type.NONE
	else:
		default_ai_personality = AIPersonality.Type.NONE
