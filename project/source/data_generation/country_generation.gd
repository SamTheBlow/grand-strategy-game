class_name CountryGeneration
## Populates given [Game] with new countries.


static func apply(game: Game, number_of_countries: int) -> void:
	if game.countries.size() > 0:
		# The code is not yet designed to be able to remove countries,
		# so for now we have to push an error and return.
		push_error("This game already has countries in it.")
		return

	for i in number_of_countries:
		var new_country: Country = Country.Factory.new(game).new_country()
		new_country.id = i
		new_country.color = Color(randf(), randf(), randf(), 1.0)
		game.countries.add(new_country)
