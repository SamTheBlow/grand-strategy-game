class_name AIRandomization
extends GameComponent
## Randomizes the AI type and/or personality for all players in the game.

const KEY: String = "ai_randomization"

const _AI_TYPE_KEY: String = "randomize_ai_type"
const _AI_PERSONALITY_KEY: String = "randomize_ai_personality"

var _randomize_type: bool = false
var _randomize_personality: bool = false


func _init() -> void:
	priority_index = 50


func run(game: Game) -> void:
	var ai_types: Array = PlayerAI.Type.values()
	ai_types.erase(PlayerAI.Type.NONE)

	var ai_perso_types: Array[int] = AIPersonality.type_values()
	ai_perso_types.erase(AIPersonality.Type.NONE)
	ai_perso_types.erase(AIPersonality.Type.ACCEPTS_EVERYTHING)

	for player in game.game_players.list():
		if _randomize_type:
			player.player_ai = PlayerAI.from_type(
					ai_types[game.rng.randi() % ai_types.size()]
			)

		if _randomize_personality:
			player.player_ai.personality = AIPersonality.from_type(
					ai_perso_types[game.rng.randi() % ai_perso_types.size()]
			)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if _randomize_type:
		output[_AI_TYPE_KEY] = _randomize_type
	if _randomize_personality:
		output[_AI_PERSONALITY_KEY] = _randomize_personality
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_bool(raw_dict, _AI_TYPE_KEY):
		_randomize_type = raw_dict[_AI_TYPE_KEY] as bool
	else:
		_randomize_type = false

	if ParseUtils.dictionary_has_bool(raw_dict, _AI_PERSONALITY_KEY):
		_randomize_personality = raw_dict[_AI_PERSONALITY_KEY] as bool
	else:
		_randomize_personality = false
