class_name GameRules
extends Resource


const RULE_NAMES: Array[String] = [
	"population_growth",
	"fortresses",
	"turn_limit_enabled",
	"turn_limit",
	"starting_money",
	"province_income_option",
	"province_income_random_min",
	"province_income_random_max",
	"province_income_constant",
	"province_income_per_person",
	"global_attacker_efficiency",
	"global_defender_efficiency",
]

enum ProvinceIncome {
	RANDOM = 0,
	CONSTANT = 1,
	POPULATION = 2,
}

@export var population_growth: bool = true
@export var fortresses: bool = false
@export var turn_limit_enabled: bool = false
@export var turn_limit: int = 50
@export var starting_money: int = 1000
@export var province_income_option: int = ProvinceIncome.POPULATION
@export var province_income_random_min: int = 10
@export var province_income_random_max: int = 100
@export var province_income_constant: int = 100
@export var province_income_per_person: float = 1.5
@export var global_attacker_efficiency: float = 1.0
@export var global_defender_efficiency: float = 1.0
