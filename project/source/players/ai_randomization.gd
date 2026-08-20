class_name AIRandomization
## Whenever the game starts, replaces all instances of
## [RandomAI] and [RandomAIPersonality] with a real instance chosen at random.
##
## Applies whenever the game starts, not just at the end of setup phase.
## This way you can choose at any time
## to randomize an AI in the save file and it'll work.


static func connect_game(game: Game) -> void:
	game.turn.started.connect(_apply.bind(game))


static func _apply(game: Game) -> void:
	var ai_types: Array = PlayerAI.Type.values()
	ai_types.erase(PlayerAI.Type.RANDOM)
	ai_types.erase(PlayerAI.Type.NONE)

	var ai_perso_types: Array[int] = AIPersonality.type_values()
	ai_perso_types.erase(AIPersonality.Type.RANDOM)
	ai_perso_types.erase(AIPersonality.Type.NONE)
	ai_perso_types.erase(AIPersonality.Type.ACCEPTS_EVERYTHING)

	for player in game.game_players.list():
		if player.player_ai is RandomAI:
			var personality: AIPersonality = player.player_ai.personality
			player.player_ai = PlayerAI.from_type(
					ai_types[game.rng.randi() % ai_types.size()]
			)
			player.player_ai.personality = personality

		if player.player_ai.personality is RandomAIPersonality:
			player.player_ai.personality = AIPersonality.from_type(
					ai_perso_types[game.rng.randi() % ai_perso_types.size()]
			)
