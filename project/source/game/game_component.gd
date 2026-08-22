@abstract
class_name GameComponent
## Base class for a script that applies arbitrary changes to some [Game].
## All subclasses must implement the constant "KEY", a string.

## Determines the order in which these components are run.
## Lower values run first.
var priority_index: int = 0


@abstract func register(_game: Game) -> void


## Provides a new instance of component with given key, if key is valid.
static func from_key(key: String) -> ParseResult:
	return from_raw_data(key, {})


## Attempts to create a new instance from given raw data.
static func from_raw_data(key: String, raw_dict: Dictionary) -> ParseResult:
	var component: GameComponent

	match key:
		RandomGridWorld.KEY:
			component = RandomGridWorld.new()
		PlayerCreation.KEY:
			component = PlayerCreation.new()
		PlayerAssignmentToCountry.KEY:
			component = PlayerAssignmentToCountry.new()
		CountryGeneration.KEY:
			component = CountryGeneration.new()
		CountryPlacementGeneration.KEY:
			component = CountryPlacementGeneration.new()
		RelationshipPresetRandomization.KEY:
			component = RelationshipPresetRandomization.new()
		TurnOrderRandomization.KEY:
			component = TurnOrderRandomization.new()
		PopulationRandomization.KEY:
			component = PopulationRandomization.new()
		PopulationGrowth.KEY:
			component = PopulationGrowth.new()
		ProvinceConstantIncome.KEY:
			component = ProvinceConstantIncome.new()
		ProvincePopulationIncome.KEY:
			component = ProvincePopulationIncome.new()
		ProvinceIncomeRandomization.KEY:
			component = ProvinceIncomeRandomization.new()
		ArmyPlacement.KEY:
			component = ArmyPlacement.new()
		BuildingPlacement.KEY:
			component = BuildingPlacement.new()
		ArmyReinforcements.KEY:
			component = ArmyReinforcements.new()
		ArmyRecruitment.KEY:
			component = ArmyRecruitment.new()
		Combat.KEY:
			component = Combat.new()
		TurnLimit.KEY:
			component = TurnLimit.new()
		ProvinceControlGoal.KEY:
			component = ProvinceControlGoal.new()
		MilitaryAccessLossBehavior.KEY:
			component = MilitaryAccessLossBehavior.new()
		DiplomacySettings.KEY:
			component = DiplomacySettings.new()
		RelationshipPresetDefault.KEY:
			component = RelationshipPresetDefault.new()
		_:
			return ResultError.new("Unrecognized component key: %s" % key)

	component._load_settings(raw_dict)
	return ResultSuccess.new(component)


func to_raw_dict() -> Dictionary:
	return {}


func _load_settings(_raw_dict: Dictionary) -> void:
	pass


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
