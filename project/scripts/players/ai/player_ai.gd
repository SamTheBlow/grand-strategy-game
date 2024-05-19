class_name PlayerAI
## Class responsible for a player's behavior when the
## player is not controlled by a human.
##
## This is the base AI class.
## You can use it as a default AI that does nothing.
## If you want to make your own AI, make a subclass of this class.


## This is where the AI generates its actions based on a given game state
func actions(_game: Game, _player: GamePlayer) -> Array[Action]:
	return []
