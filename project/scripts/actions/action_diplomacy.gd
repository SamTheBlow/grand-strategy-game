class_name ActionDiplomacy
extends Action
## Performs a given diplomatic action with given [Country].
##
## See also: [DiplomacyAction], [DiplomacyRelationship].


var _diplomacy_action_id: int = -1
var _target_country_id: int = -1


func _init(diplomacy_action_id: int, target_country_id: int) -> void:
	_diplomacy_action_id = diplomacy_action_id
	_target_country_id = target_country_id


func apply_to(game: Game, player: GamePlayer) -> void:
	var target_country: Country = (
			game.countries.country_from_id(_target_country_id)
	)
	if target_country == null:
		return
	
	var relationship: DiplomacyRelationship = (
		player.playing_country.relationships.with_country(target_country)
	)
	var reverse_relationship: DiplomacyRelationship = (
		target_country.relationships.with_country(player.playing_country)
	)
	
	relationship.action_from_id(_diplomacy_action_id).apply(
			game, relationship, reverse_relationship
	)


func raw_data() -> Dictionary:
	return {
		"id": DIPLOMACY,
		"diplomacy_action_id": _diplomacy_action_id,
		"target_country_id": _target_country_id,
	}


static func from_raw_data(data: Dictionary) -> ActionDiplomacy:
	return ActionDiplomacy.new(
		data["diplomacy_action_id"] as int,
		data["target_country_id"] as int,
	)
