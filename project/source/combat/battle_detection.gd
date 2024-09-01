class_name BattleDetection
## Detects when a [Battle] should occur and starts the battles when applicable.


var _armies: Armies
var _battle: Battle


func _init(armies: Armies, battle: Battle) -> void:
	_armies = armies
	_battle = battle
	
	for army in armies.list():
		_on_army_added(army)
	armies.army_added.connect(_on_army_added)


## Checks for [Battles] that need to occur in given [Army]'s [Province].
## Makes the battles happen, when applicable.
func _resolve_battles(army: Army) -> void:
	for other_army in _armies.armies_in_province(army.province()):
		if Country.is_fighting(army.owner_country, other_army.owner_country):
			_battle.apply(army, other_army)


func _on_army_added(army: Army) -> void:
	army.province_changed.connect(_on_army_province_changed)


func _on_army_province_changed(army: Army) -> void:
	_resolve_battles(army)
