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


static func type_names() -> Array[String]:
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


static func type_values() -> Array[int]:
	var output: Array[int] = []
	for value: Variant in Type.values():
		if value is not int:
			continue
		output.append(value)
	return output


## This is where the AI generates its actions based on a given game state.
func actions(_game: Game, _player: GamePlayer, _rng: GameRNG) -> Array[Action]:
	return []


## Returns a new AIPersonality instance of given type.
## Returns null if type is not recognized.
static func from_type(personality_type: int) -> AIPersonality:
	match personality_type:
		-1:
			return RandomAIPersonality.new()
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
			return null


## Returns this AI's type as an int, for the purposes of saving/loading.
func type() -> int:
	if self is RandomAIPersonality:
		return -1
	elif self is AIPersonalityInterventionist:
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
