class_name BattleDetection
## Detects when a [Battle] should occur and starts the battle if applicable.
# TODO just like the rest of the battle code, this is ugly


func _on_army_added(army: Army) -> void:
	army.province_changed.connect(_on_army_province_changed)


func _on_army_province_changed(army: Army, province: Province) -> void:
	_resolve_battles(army, province)


## Engages given [Army] into a battle with all
## armies in given [Province], when applicable.
func _resolve_battles(army: Army, province: Province) -> void:
	var armies_in_province: Array[Army] = (
			province.game.world.armies.armies_in_province(province)
	)
	for other_army in armies_in_province:
		if _is_fighting(army, other_army):
			_start_battle(army, other_army)


func _is_fighting(army: Army, other_army: Army) -> bool:
	return (
			army.owner_country != other_army.owner_country
			and (
					army.owner_country.relationships
					.with_country(other_army.owner_country).is_fighting()
					or
					other_army.owner_country.relationships
					.with_country(army.owner_country).is_fighting()
			)
	)


func _start_battle(attacking_army: Army, defending_army: Army) -> void:
	attacking_army.game.battle.apply(attacking_army, defending_army)
