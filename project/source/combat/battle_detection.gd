class_name BattleDetection
## Detects when a [Battle] should occur and starts the battles when applicable.

var _battle: Battle
var _armies_in_each_province: ArmiesInEachProvince


func _init(
		armies: Armies,
		armies_in_each_province: ArmiesInEachProvince,
		battle: Battle
) -> void:
	_battle = battle
	_armies_in_each_province = armies_in_each_province

	for army in armies.list():
		_connect_army(army)

	armies.added.connect(_connect_army)
	armies.removed.connect(_disconnect_army)


## Checks for [Battles] that need to occur in given [Army]'s [Province].
## Makes the battles happen, when applicable.
func _resolve_battles(army: Army) -> void:
	# Armies may get removed from the list as they destroy each other,
	# so it's important to duplicate the array.
	var armies_in_province: Array[Army] = (
			_armies_in_each_province
			.in_province_id(army.province_id()).list.duplicate()
	)
	for other_army in armies_in_province:
		if Country.is_fighting(army.owner_country, other_army.owner_country):
			_battle.apply(army, other_army)


func _connect_army(army: Army) -> void:
	army.province_changed.connect(_resolve_battles)


func _disconnect_army(army: Army) -> void:
	army.province_changed.disconnect(_resolve_battles)
