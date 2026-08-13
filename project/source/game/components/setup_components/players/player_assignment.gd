class_name PlayerAssignmentToCountry
extends GameComponent
## Assigns a random country to each (unassigned) player.
##
## If a player is already assigned to a valid country,
## it stays assigned to that country.
## Otherwise, it gets assigned to a random unassigned country.
## If all countries are already assigned,
## then the remaining players are not assigned a country.

const ID: int = 4


func _init() -> void:
	priority_index = 30


func id() -> int:
	return ID


func run(game: Game) -> void:
	# Randomly shuffled list of countries
	var country_list: Array[Country] = game.rng.shuffled(game.countries.list())

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
