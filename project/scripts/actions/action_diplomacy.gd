class_name ActionDiplomacy
extends Action
## Performs a given diplomatic action with given [Country].
##
## See also: [DiplomacyAction], [DiplomacyRelationship].


const DIPLOMACY_ACTION_ID_KEY: String = "diplomacy_action_id"
const TARGET_COUNTRY_ID_KEY: String = "target_country_id"

var _diplomacy_action_id: int = -1
var _target_country_id: int = -1


func _init(diplomacy_action_id: int, target_country_id: int) -> void:
	_diplomacy_action_id = diplomacy_action_id
	_target_country_id = target_country_id


func apply_to(game: Game, player: GamePlayer) -> void:
	var target_country_: Country = target_country(game)
	if target_country_ == null:
		return
	
	var relationship: DiplomacyRelationship = (
		player.playing_country.relationships.with_country(target_country_)
	)
	var reverse_relationship: DiplomacyRelationship = (
		target_country_.relationships.with_country(player.playing_country)
	)
	
	diplomacy_action(relationship).perform(
			game, relationship, reverse_relationship
	)


## May return null.
func target_country(game: Game) -> Country:
	return game.countries.country_from_id(_target_country_id)


func diplomacy_action(relationship: DiplomacyRelationship) -> DiplomacyAction:
	return relationship.action_from_id(_diplomacy_action_id)


func is_equivalent_to(action_diplomacy: ActionDiplomacy) -> bool:
	return (
			action_diplomacy._diplomacy_action_id == _diplomacy_action_id
			and action_diplomacy._target_country_id == _target_country_id
	) if action_diplomacy != null else false


func raw_data() -> Dictionary:
	return {
		ID_KEY: DIPLOMACY,
		DIPLOMACY_ACTION_ID_KEY: _diplomacy_action_id,
		TARGET_COUNTRY_ID_KEY: _target_country_id,
	}


static func from_raw_data(data: Dictionary) -> ActionDiplomacy:
	if not (
			ParseUtils.dictionary_has_number(data, DIPLOMACY_ACTION_ID_KEY)
			and ParseUtils.dictionary_has_number(data, TARGET_COUNTRY_ID_KEY)
	):
		return null
	
	return ActionDiplomacy.new(
			ParseUtils.dictionary_int(data, DIPLOMACY_ACTION_ID_KEY),
			ParseUtils.dictionary_int(data, TARGET_COUNTRY_ID_KEY),
	)
