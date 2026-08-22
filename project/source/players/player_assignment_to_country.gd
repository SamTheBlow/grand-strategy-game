class_name PlayerAssignmentToCountry
extends GameComponent
## During game setup,
## assigns a random unassigned country to every player without one.

const KEY: String = "player_assignment_to_country"
const TITLE: String = "Player Assignment"
const DESCRIPTION: String = "During game setup, assigns a random unassigned country to every player without one."
const SETTINGS: Array = []


func _init() -> void:
	priority_index = 30


## Registers this component to run at the end of the setup phase.
func register(game: Game) -> void:
	game.setup_ending.connect(_apply, Object.CONNECT_APPEND_SOURCE_OBJECT)


func _apply(game: Game) -> void:
	# Randomly shuffled list of countries
	var country_list: Array[Country] = game.rng.shuffled(game.countries.list)

	# List of players that need to be assigned a country
	var players_to_assign: Array[GamePlayer] = game.game_players.list()

	# Remove already assigned countries from the list of countries
	# Remove already assigned players from the list of players
	for game_player in game.game_players.list():
		if game_player.playing_country == null:
			continue

		if game_player.playing_country in country_list:
			country_list.erase(game_player.playing_country)
		players_to_assign.erase(game_player)

	# Assign players
	for game_player in players_to_assign:
		if country_list.is_empty():
			return
		game_player.playing_country = country_list.pop_back()
