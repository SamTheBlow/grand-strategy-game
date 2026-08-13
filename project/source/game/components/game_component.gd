@abstract
class_name GameComponent
## Base class for a script that applies arbitrary changes to some [Game].

const _ID_KEY: String = "id"

var error: bool = false
var error_message: String = ""

## Determines the order in which these components are run.
## Lower values run first.
var priority_index: int = 0


## This component's unique id.
@abstract func id() -> int


## If an error occurs, tells so using the error and error_message properties.
@abstract func run(_game: Game) -> void


## Attempts to create a new instance from given raw data.
static func from_raw_data(raw_data: Variant) -> ParseResult:
	if raw_data is not Dictionary:
		return ResultError.new("Component data is not a dictionary.")
	var raw_dict: Dictionary = raw_data

	# Id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, _ID_KEY):
		return ResultError.new("Component data doesn't have a valid id.")
	var loaded_id: int = ParseUtils.dictionary_int(raw_dict, _ID_KEY)

	match loaded_id:
		RandomGridWorld.ID:
			return _component_from_raw_data(RandomGridWorld.new(), raw_dict)
		MiscGameGeneration.ID:
			return _component_from_raw_data(MiscGameGeneration.new(), raw_dict)
		RNGOverwrite.ID:
			return _component_from_raw_data(RNGOverwrite.new(), raw_dict)
		PlayerCreation.ID:
			return _component_from_raw_data(PlayerCreation.new(), raw_dict)
		PlayerAssignmentToCountry.ID:
			return _component_from_raw_data(
					PlayerAssignmentToCountry.new(), raw_dict
			)
		CountryGeneration.ID:
			return _component_from_raw_data(CountryGeneration.new(), raw_dict)
		CountryPlacementGeneration.ID:
			return _component_from_raw_data(
					CountryPlacementGeneration.new(), raw_dict
			)
		RelationshipPresetRandomization.ID:
			return _component_from_raw_data(
					RelationshipPresetRandomization.new(), raw_dict
			)
		AIRandomization.ID:
			return _component_from_raw_data(AIRandomization.new(), raw_dict)
		TurnOrderRandomization.ID:
			return _component_from_raw_data(
					TurnOrderRandomization.new(), raw_dict
			)
		_:
			return ResultError.new("Unrecognized component id: %s" % loaded_id)


## Attempts to load given component's settings using given raw data.
static func _component_from_raw_data(
		component: GameComponent, raw_dict: Dictionary
) -> ParseResult:
	component._load_settings(raw_dict)
	if component.error:
		return ResultError.new(component.error_message)
	return ResultSuccess.new(component)


func to_raw_data() -> Variant:
	return { _ID_KEY: id() }


## If an error occurs, tells so using the error and error_message properties.
func _load_settings(_raw_dict: Dictionary) -> void:
	error = false
	error_message = ""


@abstract class ParseResult:
	var error: bool = false
	var error_message: String = ""
	var result_component: GameComponent = null


class ResultError extends ParseResult:
	func _init(message: String) -> void:
		error = true
		error_message = message


class ResultSuccess extends ParseResult:
	func _init(result: GameComponent) -> void:
		result_component = result
