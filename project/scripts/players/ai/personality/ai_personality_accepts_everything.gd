class_name AIAcceptsEverything
extends AIPersonality
## This AI personality simply accepts all offers, and does nothing else.
## It's not meant to be a fun/challenging opponent.


func actions(game: Game, _player: GamePlayer) -> Array[Action]:
	var decisions := AIDecisionUtils.new(game)
	decisions.accept_all_offers()
	return decisions.action_list()
