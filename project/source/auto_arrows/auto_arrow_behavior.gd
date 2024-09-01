class_name AutoArrowBehavior
## Applies army split and movement according to the game's [AutoArrow]s.


func apply(game: Game) -> void:
	var player: GamePlayer = game.turn.playing_player()
	
	# Get the source provinces and the arrow destinations.
	# Each source province has its own list of arrow destinations.
	var source_provinces: Array[Province] = []
	var arrow_destinations: Array[ArrowDestinations] = []
	for auto_arrow in player.playing_country.auto_arrows.list():
		var source_province_index: int = (
				source_provinces.find(auto_arrow.source_province)
		)
		if source_province_index == -1:
			source_province_index = source_provinces.size()
			arrow_destinations.append(ArrowDestinations.new())
			source_provinces.append(auto_arrow.source_province)
		arrow_destinations[source_province_index].add(
				auto_arrow.destination_province
		)
	
	for i in source_provinces.size():
		var source_province: Province = source_provinces[i]
		for army in (
				game.world.armies
				.active_armies(player.playing_country, source_province)
		):
			# Here we don't use [ActionSynchronizer] because this function
			# is already going to be called on all clients anyway,
			# and the clients already have the information they need
			# (ATTENTION) assuming the [AutoArrowNode2D]s are correctly synced
			var army_even_split := ArmyEvenSplit.new()
			army_even_split.apply(army, arrow_destinations[i].destinations)
			if army_even_split.action_army_split != null:
				army_even_split.action_army_split.apply_to(game, player)
			for action in army_even_split.action_army_movements:
				action.apply_to(game, player)


## List of provinces.
## Each source province has its own list of destination provinces,
## as defined by the country's autoarrows.
class ArrowDestinations:
	var destinations: Array[Province] = []
	
	
	func add(destination_province: Province) -> void:
		destinations.append(destination_province)
	
	
	func number_of_destinations() -> int:
		return destinations.size()
