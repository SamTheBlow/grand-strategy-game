class_name AIAcceptsEverything
extends AIPersonality
## This AI personality simply accepts all offers, and does nothing else.
## It's not meant to be a fun/challenging opponent.


func actions(_game: Game, player: GamePlayer) -> Array[Action]:
	var new_actions: Array[Action] = []
	for i in player.playing_country.notifications.list().size():
		# NOTE assumes that the outcome with index 0 is for accepting
		new_actions.append(ActionHandleNotification.new(0, 0))
	return new_actions
