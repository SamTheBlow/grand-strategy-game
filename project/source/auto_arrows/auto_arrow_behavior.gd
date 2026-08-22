class_name AutoArrowBehavior
## Applies army split and movement according to the game's [AutoArrow]s.


static func apply(game: Game) -> void:
	if not game.turn.is_running():
		return
	var playing_country: Country = game.turn.playing_country()
	var player: GamePlayer = game.turn.playing_players()[0]

	# Get the source provinces and the arrow destinations.
	# Each source province has its own list of arrow destinations.
	var arrow_destinations: Dictionary[Province, ArrowDestinations] = {}
	for auto_arrow in playing_country.auto_arrows.list():
		var source_province: Province = game.world.provinces.map.get(
				auto_arrow.source_province_id()
		)
		if source_province == null:
			continue
		var destination_province: Province = (
				game.world.provinces.map.get(
						auto_arrow.destination_province_id()
				)
		)
		if destination_province == null:
			continue
		if not source_province.is_linked_to(destination_province.id):
			continue

		if not arrow_destinations.has(source_province):
			arrow_destinations[source_province] = ArrowDestinations.new()
		arrow_destinations[source_province].add(destination_province)

	for source_province in arrow_destinations:
		for army in (
				game.world.armies_in_each_province
				.dictionary[source_province.id].ordered_list
		):
			if not (
					army.owner_country == playing_country
					and army.is_able_to_move()
			):
				continue

			# Remove the provinces that this army can't go to
			for destination_province: Province in (
					arrow_destinations[source_province].destinations
					.duplicate()
			):
				if not army.can_move_to(
						game.world.provinces, destination_province.id
				):
					arrow_destinations[source_province].destinations.erase(
							destination_province
					)

			# Here we don't use [ActionSynchronizer] because this function
			# is already going to be called on all clients anyway,
			# and the clients already have the information they need
			# (ATTENTION) assuming the [AutoArrowNode2D]s are correctly synced
			var army_even_split := (
					ArmyEvenSplit.new(game.world.armies.id_system())
			)
			army_even_split.apply(
					army, arrow_destinations[source_province].destinations
			)
			if army_even_split.action_army_split != null:
				army_even_split.action_army_split.apply_to(game, player)
			for action in army_even_split.action_army_movements:
				action.apply_to(game, player)


## List of provinces.
## Each source province has its own list of destination provinces,
## as defined by the country's autoarrows.
class ArrowDestinations:
	var destinations: Array[Province] = []

	## No effect if destination is null or is already in the list.
	func add(destination: Province) -> void:
		if destination != null and not destinations.has(destination):
			destinations.append(destination)
