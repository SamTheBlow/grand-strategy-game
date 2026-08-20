class_name PlayerAI
## Class responsible for a [GamePlayer]'s behavior when the
## player is not controlled by a human.
##
## This is the base AI class.
## You can use it as a default AI that does nothing.
## If you want to make your own AI, create a subclass of this class
## and add it to the Type enum, and the from_type() and type() functions.

signal personality_changed()

enum Type {
	RANDOM = -1,
	NONE = 0,
	TESTAI1 = 1,
	TESTAI2 = 2,
}

## This is responsible for the AI's diplomatic actions. It must not be null.
var personality := AIPersonality.from_type(AIPersonality.Type.NONE):
	set(value):
		if personality == value:
			return
		personality = value
		personality_changed.emit()


## This is where the AI generates its actions based on a given game state.
func actions(game: Game, player: GamePlayer) -> Array[Action]:
	# Create a duplicate of the RNG to avoid mutating game state
	var rng_copy := GameRNGStepCounted.new(game.rng)
	var output: Array[Action] = _actions(game, player, rng_copy)

	# Advance the RNG state by however many steps the AI did
	var step_count: int = rng_copy.step_count()
	if step_count > 0:
		output.append(ActionAdvanceRNG.new(step_count))

	return output


func _actions(game: Game, player: GamePlayer, rng: GameRNG) -> Array[Action]:
	return personality.actions(game, player, rng)


## Returns a new PlayerAI instance of given type.
## Returns null if type is not recognized.
static func from_type(ai_type: int) -> PlayerAI:
	match ai_type:
		Type.RANDOM:
			return RandomAI.new()
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
	if self is RandomAI:
		return Type.RANDOM
	elif self is TestAI1:
		return Type.TESTAI1
	elif self is TestAI2:
		return Type.TESTAI2
	return Type.NONE
