class_name PlayerAI
## Class responsible for a [GamePlayer]'s behavior when the
## player is not controlled by a human.
##
## This is the base AI class.
## You can use it as a default AI that does nothing.
## If you want to make your own AI, create a subclass of this class
## and add it to the Type enum, and the from_type() and type() functions.


enum Type {
	NONE = 0,
	TESTAI1 = 1,
	TESTAI2 = 2,
}

## This is responsible for the AI's diplomatic actions. It must not be null.
var personality := AIPersonality.from_type(AIPersonality.Type.NONE)


## This is where the AI generates its actions based on a given game state.
func actions(game: Game, player: GamePlayer) -> Array[Action]:
	return personality.actions(game, player)


## Returns a new PlayerAI of given type, for the purposes of saving/loading.
static func from_type(ai_type: int) -> PlayerAI:
	match ai_type:
		Type.NONE:
			return PlayerAI.new()
		Type.TESTAI1:
			return TestAI1.new()
		Type.TESTAI2:
			return TestAI2.new()
		_:
			push_error("Unrecognized AI type.")
			return null


## Returns this AI's type as an int, for the purposes of saving/loading.
func type() -> int:
	if self is TestAI1:
		return Type.TESTAI1
	elif self is TestAI2:
		return Type.TESTAI2
	return Type.NONE
