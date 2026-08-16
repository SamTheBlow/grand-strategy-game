class_name ProvinceOwnershipUpdate
## Updates the owner country of each province at the end of each country's turn.


static func connect_game(game: Game) -> void:
	game.turn.country_turn_ended.connect(_apply.bind(game).unbind(1))


static func _apply(game: Game) -> void:
	for province in game.world.provinces.list:
		var current_owner: Country = province.owner_country
		var new_owner: Country = current_owner

		for army in (
				game.world.armies_in_each_province.dictionary[province.id]
				.ordered_list
		):
			# If the current owner has an army here,
			# then the province can't be taken by someone else.
			if army.owner_country == current_owner:
				new_owner = current_owner
				break

			# Priority goes to the first army that landed here.
			# Once we've found a new owner, we don't need to search anymore.
			# However, we can't just break out of the loop, because we still
			# need to check for armies owned by the current owner.
			if new_owner != current_owner:
				continue

			# If this army is not trespassing,
			# then it won't take control over the province.
			# See [DiplomacyRelationship]
			if not army.is_trespassing(game.world.provinces):
				continue

			new_owner = army.owner_country

		province.owner_country = new_owner
