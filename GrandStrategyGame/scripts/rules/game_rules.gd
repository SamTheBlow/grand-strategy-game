class_name GameRules
extends Resource


const RULE_NAMES: Array[String] = [
	"turn_limit_enabled",
	"turn_limit",
	"reinforcements_enabled",
	"reinforcements_option",
	"reinforcements_random_min",
	"reinforcements_random_max",
	"reinforcements_constant",
	"reinforcements_per_person",
	"population_growth",
	"extra_starting_population",
	"start_with_fortress",
	"can_buy_fortress",
	"fortress_price",
	"starting_money",
	"province_income_option",
	"province_income_random_min",
	"province_income_random_max",
	"province_income_constant",
	"province_income_per_person",
	"global_attacker_efficiency",
	"global_defender_efficiency",
]

enum ReinforcementsOption {
	RANDOM = 0,
	CONSTANT = 1,
	POPULATION = 2,
}

enum ProvinceIncome {
	RANDOM = 0,
	CONSTANT = 1,
	POPULATION = 2,
}

@export var turn_limit_enabled: bool = false
@export var turn_limit: int = 50
@export var reinforcements_enabled: bool = true
@export var reinforcements_option: int = ReinforcementsOption.POPULATION
@export var reinforcements_random_min: int = 10
@export var reinforcements_random_max: int = 40
@export var reinforcements_constant: int = 0
@export var reinforcements_per_person: float = 1.0
@export var population_growth: bool = true
@export var extra_starting_population: int = 0
@export var start_with_fortress: bool = true
@export var can_buy_fortress: bool = true
@export var fortress_price: int = 500
@export var starting_money: int = 1000
@export var province_income_option: int = ProvinceIncome.POPULATION
@export var province_income_random_min: int = 10
@export var province_income_random_max: int = 100
@export var province_income_constant: int = 100
@export var province_income_per_person: float = 1.5
@export var global_attacker_efficiency: float = 1.0
@export var global_defender_efficiency: float = 1.0
