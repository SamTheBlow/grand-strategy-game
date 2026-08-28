class_name Combat
extends GameComponent
## Enables combat between opposing armies.

const KEY: String = "combat"
const TITLE: String = "Combat"
const DESCRIPTION: String = "Enables combat between opposing armies."
const SETTINGS: Array = [
	{ "property_name": _ATTACKER_EFFICIENCY_KEY, "text": "Global attacker efficiency", "type": "float" },
	{ "property_name": _DEFENDER_EFFICIENCY_KEY, "text": "Global defender efficiency", "type": "float" },
	{ "property_name": _ALGORITHM_ID_KEY, "text": "Battle algorithm", "type": "options", "options": ["Standard", "Algorithm 2"], "option_map": [0, 1] },
]

const _ATTACKER_EFFICIENCY_KEY: String = "global_attacker_efficiency"
const _DEFENDER_EFFICIENCY_KEY: String = "global_defender_efficiency"
const _ALGORITHM_ID_KEY: String = "algorithm_id"

var global_attacker_efficiency: float = 1.0
var global_defender_efficiency: float = 1.0

## Which battle algorithm is used to resolve battles.
## 0 = Standard, 1 = Algorithm 2.
var algorithm_id: int = 0

var _game: Game


func _init() -> void:
	priority_index = 0


func register(game: Game) -> void:
	_game = game

	game.modifier_request.add_provider(self)

	for army in game.world.armies.list():
		_connect_army(army)
	game.world.armies.added.connect(_connect_army)
	game.world.armies.removed.connect(_disconnect_army)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if global_attacker_efficiency != 1.0:
		output[_ATTACKER_EFFICIENCY_KEY] = global_attacker_efficiency
	if global_defender_efficiency != 1.0:
		output[_DEFENDER_EFFICIENCY_KEY] = global_defender_efficiency
	if algorithm_id != 0:
		output[_ALGORITHM_ID_KEY] = algorithm_id
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	if ParseUtils.dictionary_has_number(raw_dict, _ATTACKER_EFFICIENCY_KEY):
		global_attacker_efficiency = ParseUtils.dictionary_float(
				raw_dict, _ATTACKER_EFFICIENCY_KEY
		)
	else:
		global_attacker_efficiency = 1.0

	if ParseUtils.dictionary_has_number(raw_dict, _DEFENDER_EFFICIENCY_KEY):
		global_defender_efficiency = ParseUtils.dictionary_float(
				raw_dict, _DEFENDER_EFFICIENCY_KEY
		)
	else:
		global_defender_efficiency = 1.0

	if ParseUtils.dictionary_has_number(raw_dict, _ALGORITHM_ID_KEY):
		algorithm_id = ParseUtils.dictionary_int(
				raw_dict, _ALGORITHM_ID_KEY
		)
	else:
		algorithm_id = 0


func _connect_army(army: Army) -> void:
	army.province_changed.connect(_resolve_battles)


func _disconnect_army(army: Army) -> void:
	army.province_changed.disconnect(_resolve_battles)


## Checks for [Battles] that need to occur in given [Army]'s [Province].
## Makes the battles happen, when applicable.
func _resolve_battles(army: Army) -> void:
	if not _game.turn.is_running():
		return

	# Armies may get removed from the list as they destroy each other,
	# so it's important to duplicate the array.
	var armies_in_province: Array[Army] = (
			_game.world.armies_in_each_province.dictionary[army.province_id()]
			.ordered_list.duplicate()
	)
	for other_army in armies_in_province:
		if Country.is_fighting(army.owner_country, other_army.owner_country):
			Battle.new(algorithm_id, _game.modifier_request).apply(
					army, other_army
			)


## Adds this module's global efficiency modifiers to the request when asked.
func _on_modifiers_requested(
		modifiers: Array[Modifier],
		context: ModifierRequest.Context,
		_defending_army: Army
) -> void:
	match context:
		ModifierRequest.Context.ATTACKER_EFFICIENCY:
			if global_attacker_efficiency != 1.0:
				modifiers.append(ModifierMultiplier.new(
						"Base Modifier",
						"Attackers all have this modifier by default.",
						global_attacker_efficiency
				))
		ModifierRequest.Context.DEFENDER_EFFICIENCY:
			if global_defender_efficiency != 1.0:
				modifiers.append(ModifierMultiplier.new(
						"Base Modifier",
						"Defenders all have this modifier by default.",
						global_defender_efficiency
				))
