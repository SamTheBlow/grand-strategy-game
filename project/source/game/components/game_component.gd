@abstract
class_name GameComponent
## Base class for a script that applies arbitrary changes to some [Game].
## All subclasses must implement the constant "KEY", a string.

var error: bool = false
var error_message: String = ""

## Determines the order in which these components are run.
## Lower values run first.
var priority_index: int = 0


@abstract func register(_game: Game) -> void


## Attempts to create a new instance from given raw data.
static func from_raw_data(key: String, raw_dict: Dictionary) -> ParseResult:
	match key:
		RandomGridWorld.KEY:
			return _component_from_raw_data(RandomGridWorld.new(), raw_dict)
		MiscGameGeneration.KEY:
			return _component_from_raw_data(MiscGameGeneration.new(), raw_dict)
		RNGOverwrite.KEY:
			return _component_from_raw_data(RNGOverwrite.new(), raw_dict)
		PlayerCreation.KEY:
			return _component_from_raw_data(PlayerCreation.new(), raw_dict)
		PlayerAssignmentToCountry.KEY:
			return _component_from_raw_data(
					PlayerAssignmentToCountry.new(), raw_dict
			)
		CountryGeneration.KEY:
			return _component_from_raw_data(CountryGeneration.new(), raw_dict)
		CountryPlacementGeneration.KEY:
			return _component_from_raw_data(
					CountryPlacementGeneration.new(), raw_dict
			)
		RelationshipPresetRandomization.KEY:
			return _component_from_raw_data(
					RelationshipPresetRandomization.new(), raw_dict
			)
		AIRandomization.KEY:
			return _component_from_raw_data(AIRandomization.new(), raw_dict)
		TurnOrderRandomization.KEY:
			return _component_from_raw_data(
					TurnOrderRandomization.new(), raw_dict
			)
		PopulationGrowth.KEY:
			return _component_from_raw_data(PopulationGrowth.new(), raw_dict)
		ProvinceConstantIncome.KEY:
			return _component_from_raw_data(
					ProvinceConstantIncome.new(), raw_dict
			)
		ProvincePopulationIncome.KEY:
			return _component_from_raw_data(
					ProvincePopulationIncome.new(), raw_dict
			)
		ProvinceIncomeRandomization.KEY:
			return _component_from_raw_data(
					ProvinceIncomeRandomization.new(), raw_dict
			)
		ArmyReinforcements.KEY:
			return _component_from_raw_data(ArmyReinforcements.new(), raw_dict)
		TurnLimit.KEY:
			return _component_from_raw_data(TurnLimit.new(), raw_dict)
		ProvinceControlGoal.KEY:
			return _component_from_raw_data(ProvinceControlGoal.new(), raw_dict)
		MilitaryAccessLossBehavior.KEY:
			return _component_from_raw_data(
					MilitaryAccessLossBehavior.new(), raw_dict
			)
		_:
			return ResultError.new("Unrecognized component key: %s" % key)


## Attempts to load given component's settings using given raw data.
static func _component_from_raw_data(
		component: GameComponent, raw_dict: Dictionary
) -> ParseResult:
	component._load_settings(raw_dict)
	if component.error:
		return ResultError.new(component.error_message)
	return ResultSuccess.new(component)


func to_raw_dict() -> Dictionary:
	return {}


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
