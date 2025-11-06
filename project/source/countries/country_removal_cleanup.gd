class_name CountryRemovalCleanup
## Ensures all objects in given [Game]
## stop using a country as soon as it's removed from the game.
# TODO This class shouldn't exist!
# Objects should ensure they're not using a removed country, all by themselves.


func _init(game: Game) -> void:
	game.countries.removed.connect(_on_country_removed.bind(game))


func _on_country_removed(country: Country, game: Game) -> void:
	# [GamePlayer]
	for player in game.game_players.list():
		if player.playing_country == country:
			player.playing_country = null

	# [DiplomacyRelationships]
	# NOTE: I'm not sure this is 100% going to remove the country
	# from all relationships, but it seems good enough.
	for other_country in country.relationships.list:
		other_country.relationships.list.erase(country)
	country.relationships.list = {}
