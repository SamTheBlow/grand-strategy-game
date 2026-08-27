class_name DiplomacySettings
extends GameComponent
## General settings and automated behaviors related to diplomacy.

const KEY: String = "diplomacy_settings"
const TITLE: String = "Diplomacy Settings"
const DESCRIPTION: String = "General settings and automated behaviors related to diplomacy."
const SETTINGS: Array = [
	{ "property_name": _MUTUAL_ACCESS_KEY, "text": "Auto mutual access", "type": "bool" },
	{ "property_name": _FIGHT_TRESPASSERS_KEY, "text": "Auto fight trespassers", "type": "bool" },
	{ "property_name": _REVOKE_ACCESS_KEY, "text": "Auto revoke access", "type": "bool" },
	{ "property_name": _FIGHT_BACK_KEY, "text": "Auto fight back", "type": "bool" },
	{ "property_name": _GRANTS_ACCESS_KEY, "text": "Grants access by default", "type": "bool" },
	{ "property_name": _CAN_GRANT_ACCESS_KEY, "text": "Can grant access", "type": "bool" },
	{ "property_name": _CAN_REVOKE_ACCESS_KEY, "text": "Can revoke access", "type": "bool" },
	{ "property_name": _CAN_ASK_ACCESS_KEY, "text": "Can ask for access", "type": "bool" },
	{ "property_name": _TRESPASSING_DEFAULT_KEY, "text": "Trespassing by default", "type": "bool" },
	{ "property_name": _CAN_ENABLE_TRESPASSING_KEY, "text": "Can enable trespassing", "type": "bool" },
	{ "property_name": _CAN_DISABLE_TRESPASSING_KEY, "text": "Can disable trespassing", "type": "bool" },
	{ "property_name": _CAN_ASK_STOP_TRESPASSING_KEY, "text": "Can ask to stop trespassing", "type": "bool" },
	{ "property_name": _FIGHTING_DEFAULT_KEY, "text": "Fighting by default", "type": "bool" },
	{ "property_name": _CAN_ENABLE_FIGHTING_KEY, "text": "Can enable fighting", "type": "bool" },
	{ "property_name": _CAN_DISABLE_FIGHTING_KEY, "text": "Can disable fighting", "type": "bool" },
	{ "property_name": _CAN_ASK_STOP_FIGHTING_KEY, "text": "Can ask to stop fighting", "type": "bool" },
]

const _MUTUAL_ACCESS_KEY: String = "auto_mutual_access"
const _FIGHT_TRESPASSERS_KEY: String = "auto_fight_trespassers"
const _REVOKE_ACCESS_KEY: String = "auto_revoke_access"
const _FIGHT_BACK_KEY: String = "auto_fight_back"

const _GRANTS_ACCESS_KEY: String = "grants_military_access_default"
const _CAN_GRANT_ACCESS_KEY: String = "can_grant_military_access"
const _CAN_REVOKE_ACCESS_KEY: String = "can_revoke_military_access"
const _CAN_ASK_ACCESS_KEY: String = "can_ask_for_military_access"

const _TRESPASSING_DEFAULT_KEY: String = "is_trespassing_default"
const _CAN_ENABLE_TRESPASSING_KEY: String = "can_enable_trespassing"
const _CAN_DISABLE_TRESPASSING_KEY: String = "can_disable_trespassing"
const _CAN_ASK_STOP_TRESPASSING_KEY: String = "can_ask_to_stop_trespassing"

const _FIGHTING_DEFAULT_KEY: String = "is_fighting_default"
const _CAN_ENABLE_FIGHTING_KEY: String = "can_enable_fighting"
const _CAN_DISABLE_FIGHTING_KEY: String = "can_disable_fighting"
const _CAN_ASK_STOP_FIGHTING_KEY: String = "can_ask_to_stop_fighting"

## Countries automatically grant military access to whoever grants it to them.
var auto_mutual_access: bool = false
## Countries automatically start fighting who trespasses in their territory.
var auto_fight_trespassers: bool = false
## Countries automatically revoke military access when fighting.
var auto_revoke_access: bool = false
## Countries automatically start fighting with whoever fights them.
var auto_fight_back: bool = false

var grants_military_access_default: bool = false
var can_grant_military_access: bool = false
var can_revoke_military_access: bool = false
var can_ask_for_military_access: bool = false

var is_trespassing_default: bool = false
var can_enable_trespassing: bool = false
var can_disable_trespassing: bool = false
var can_ask_to_stop_trespassing: bool = false

var is_fighting_default: bool = false
var can_enable_fighting: bool = false
var can_disable_fighting: bool = false
var can_ask_to_stop_fighting: bool = false

var _game: Game


func _init() -> void:
	priority_index = 0


func register(game: Game) -> void:
	_game = game

	for country in _game.countries.list:
		_connect_country(country)

	game.countries.added.connect(_connect_country)
	game.countries.removed.connect(_disconnect_country)


func to_raw_dict() -> Dictionary:
	var output: Dictionary = {}
	if auto_mutual_access:
		output[_MUTUAL_ACCESS_KEY] = true
	if auto_fight_trespassers:
		output[_FIGHT_TRESPASSERS_KEY] = true
	if auto_revoke_access:
		output[_REVOKE_ACCESS_KEY] = true
	if auto_fight_back:
		output[_FIGHT_BACK_KEY] = true
	if grants_military_access_default:
		output[_GRANTS_ACCESS_KEY] = true
	if can_grant_military_access:
		output[_CAN_GRANT_ACCESS_KEY] = true
	if can_revoke_military_access:
		output[_CAN_REVOKE_ACCESS_KEY] = true
	if can_ask_for_military_access:
		output[_CAN_ASK_ACCESS_KEY] = true
	if is_trespassing_default:
		output[_TRESPASSING_DEFAULT_KEY] = true
	if can_enable_trespassing:
		output[_CAN_ENABLE_TRESPASSING_KEY] = true
	if can_disable_trespassing:
		output[_CAN_DISABLE_TRESPASSING_KEY] = true
	if can_ask_to_stop_trespassing:
		output[_CAN_ASK_STOP_TRESPASSING_KEY] = true
	if is_fighting_default:
		output[_FIGHTING_DEFAULT_KEY] = true
	if can_enable_fighting:
		output[_CAN_ENABLE_FIGHTING_KEY] = true
	if can_disable_fighting:
		output[_CAN_DISABLE_FIGHTING_KEY] = true
	if can_ask_to_stop_fighting:
		output[_CAN_ASK_STOP_FIGHTING_KEY] = true
	return output


func _load_settings(raw_dict: Dictionary) -> void:
	auto_mutual_access = _bool_data(raw_dict, _MUTUAL_ACCESS_KEY)
	auto_fight_trespassers = _bool_data(raw_dict, _FIGHT_TRESPASSERS_KEY)
	auto_revoke_access = _bool_data(raw_dict, _REVOKE_ACCESS_KEY)
	auto_fight_back = _bool_data(raw_dict, _FIGHT_BACK_KEY)

	grants_military_access_default = _bool_data(raw_dict, _GRANTS_ACCESS_KEY)
	can_grant_military_access = _bool_data(raw_dict, _CAN_GRANT_ACCESS_KEY)
	can_revoke_military_access = _bool_data(raw_dict, _CAN_REVOKE_ACCESS_KEY)
	can_ask_for_military_access = _bool_data(raw_dict, _CAN_ASK_ACCESS_KEY)

	is_trespassing_default = _bool_data(raw_dict, _TRESPASSING_DEFAULT_KEY)
	can_enable_trespassing = _bool_data(raw_dict, _CAN_ENABLE_TRESPASSING_KEY)
	can_disable_trespassing = (
			_bool_data(raw_dict, _CAN_DISABLE_TRESPASSING_KEY)
	)
	can_ask_to_stop_trespassing = (
			_bool_data(raw_dict, _CAN_ASK_STOP_TRESPASSING_KEY)
	)

	is_fighting_default = _bool_data(raw_dict, _FIGHTING_DEFAULT_KEY)
	can_enable_fighting = _bool_data(raw_dict, _CAN_ENABLE_FIGHTING_KEY)
	can_disable_fighting = _bool_data(raw_dict, _CAN_DISABLE_FIGHTING_KEY)
	can_ask_to_stop_fighting = (
			_bool_data(raw_dict, _CAN_ASK_STOP_FIGHTING_KEY)
	)


func _bool_data(raw_dict: Dictionary, key: String) -> bool:
	if ParseUtils.dictionary_has_bool(raw_dict, key):
		return raw_dict[key]
	return false


func _connect_country(country: Country) -> void:
	for other_country in country.relationships.list:
		_connect_relationship(country.relationships.list[other_country])
	country.relationships.relationship_created.connect(_connect_relationship)


func _disconnect_country(country: Country) -> void:
	country.relationships.relationship_created.disconnect(_connect_relationship)


func _connect_relationship(relationship: DiplomacyRelationship) -> void:
	relationship.military_access_changed.connect(_on_military_access_changed)
	relationship.trespassing_changed.connect(_on_trespassing_changed)
	relationship.fighting_changed.connect(_on_fighting_changed)


func _apply_data(relationship: DiplomacyRelationship, data: Dictionary) -> void:
	relationship.recipient_country.relationships.with_country(
			relationship.source_country
	).apply_action_data(data, _game.turn.current_turn())


func _on_military_access_changed(relationship: DiplomacyRelationship) -> void:
	if auto_mutual_access and relationship.grants_military_access():
		_apply_data(relationship, { "grants_military_access": true })


func _on_trespassing_changed(relationship: DiplomacyRelationship) -> void:
	if auto_fight_trespassers and relationship.is_trespassing():
		_apply_data(relationship, { "is_fighting": true })


func _on_fighting_changed(relationship: DiplomacyRelationship) -> void:
	if auto_revoke_access and relationship.is_fighting():
		_apply_data(relationship, { "grants_military_access": false })

	if auto_fight_back and relationship.is_fighting():
		_apply_data(relationship, { "is_fighting": true })
