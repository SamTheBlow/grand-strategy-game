class_name BattleDetection
## Detects when a [Battle] should occur and starts the battle if applicable.
# TODO just like the rest of the battle code, this is ugly


func _on_army_added(army: Army) -> void:
	army.province_changed.connect(_on_army_province_changed)


func _on_army_province_changed(army: Army, province: Province) -> void:
	_resolve_battles(army, province)


## Engages given [Army] into a battle with all armies in given [Province]
## that are not under control of the same [Country] as this one.
func _resolve_battles(army: Army, province: Province) -> void:
	var armies_in_province: Array[Army] = (
			province.game.world.armies.armies_in_province(province)
	)
	for other_army in armies_in_province:
		if other_army.owner_country != army.owner_country:
			_start_battle(army, other_army)


func _start_battle(attacking_army: Army, defending_army: Army) -> void:
	attacking_army.game.battle.apply(attacking_army, defending_army)
