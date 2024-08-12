class_name AIPersonality
## Base class. Defines AI diplomatic behavior.
##
## You can use this class as a default personality that does nothing.
## If you want to add a new personality, create a subclass
## and add the relevant information in this class's enum and functions.


enum Type {
	NONE = 0,
	INTERVENTIONIST = 1,
	ISOLATIONIST = 2,
	SHY = 3,
	GREEDY = 4,
	EMOTIONAL = 5,
	ERRATIC = 6,
	ACCEPTS_EVERYTHING = 7,
}

## The type to be used by default in game rules and such.
const DEFAULT_TYPE: Type = Type.NONE


static func all_type_names() -> Array[String]:
	return [
		"None",
		"Interventionist",
		"Isolationist",
		"Shy",
		"Greedy",
		"Emotional",
		"Erratic",
		"Test AI: accepts everything",
	]


## This is where the AI generates its actions based on a given game state.
func actions(_game: Game, _player: GamePlayer) -> Array[Action]:
	return []


## Returns a new AIPersonality of given type,
## for the purposes of saving/loading.
## If the given type is invalid, returns null.
static func from_type(personality_type: int) -> AIPersonality:
	match personality_type:
		Type.NONE:
			return AIPersonality.new()
		Type.INTERVENTIONIST:
			return AIPersonalityInterventionist.new()
		Type.ISOLATIONIST:
			return AIPersonalityIsolationist.new()
		Type.SHY:
			return AIPersonalityShy.new()
		Type.GREEDY:
			return AIPersonalityGreedy.new()
		Type.EMOTIONAL:
			return AIPersonalityEmotional.new()
		Type.ERRATIC:
			return AIPersonalityErratic.new()
		Type.ACCEPTS_EVERYTHING:
			return AIAcceptsEverything.new()
		_:
			push_error("Unrecognized AI personality type.")
			return null


## Returns this AI's type as an int, for the purposes of saving/loading.
func type() -> int:
	if self is AIPersonalityInterventionist:
		return Type.INTERVENTIONIST
	elif self is AIPersonalityIsolationist:
		return Type.ISOLATIONIST
	elif self is AIPersonalityShy:
		return Type.SHY
	elif self is AIPersonalityGreedy:
		return Type.GREEDY
	elif self is AIPersonalityEmotional:
		return Type.EMOTIONAL
	elif self is AIPersonalityErratic:
		return Type.ERRATIC
	elif self is AIAcceptsEverything:
		return Type.ACCEPTS_EVERYTHING
	return Type.NONE
