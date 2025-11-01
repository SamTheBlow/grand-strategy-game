class_name CountryRelationshipNode
extends Control
## Displays information about the
## [DiplomacyRelationship] between two given countries.
##
## Hides itself when either country_1 or country_2 is null.
## Also hides itself when both given countries are the same.

signal diplomacy_action_pressed(
		diplomacy_action: DiplomacyAction, recipient_country: Country
)

@export var diplomacy_action_button_scene: PackedScene

var country_1: Country:
	set(value):
		country_1 = value
		_refresh()

var country_2: Country:
	set(value):
		country_2 = value
		_refresh()

## This can stay null. If so, the available actions will never be shown,
## and it will be assumed that relationship presets are disabled.
var game: Game:
	set(value):
		game = value
		_refresh_available_actions()

@onready var _container := %Container as Control
@onready var _data_container := %DataContainer as Control
@onready var _preset := %Preset as RelationshipInfoNode
@onready var _grants_military_access_info := (
		%GrantsMilitaryAccessInfo as RelationshipInfoNode
)
@onready var _is_trespassing_info := (
		%IsTrespassingInfo as RelationshipInfoNode
)
@onready var _is_fighting_info := (
		%IsFightingInfo as RelationshipInfoNode
)
@onready var _actions_container := %ActionsContainer as Control
@onready var _available_actions := %AvailableActions as VBoxContainer


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if country_1 == null or country_2 == null or country_1 == country_2:
		hide()
		return

	_refresh_info()
	_refresh_available_actions()
	show()


func _connect_relationship_signals(
		relationship: DiplomacyRelationship
) -> void:
	if (
			not relationship.preset_changed
			.is_connected(_on_relationship_data_changed)
	):
		relationship.preset_changed.connect(_on_relationship_data_changed)
	if (
			not relationship.military_access_changed
			.is_connected(_on_relationship_data_changed)
	):
		relationship.military_access_changed.connect(
				_on_relationship_data_changed
		)
	if (
			not relationship.trespassing_changed
			.is_connected(_on_relationship_data_changed)
	):
		relationship.trespassing_changed.connect(_on_relationship_data_changed)
	if (
			not relationship.fighting_changed
			.is_connected(_on_relationship_data_changed)
	):
		relationship.fighting_changed.connect(_on_relationship_data_changed)
	if (
			not relationship.available_actions_changed
			.is_connected(_on_available_actions_changed)
	):
		relationship.available_actions_changed.connect(
				_on_available_actions_changed
		)


func _update_minimum_height() -> void:
	if not is_node_ready():
		return

	_update_minimum_height_of(_data_container)
	_update_minimum_height_of(_available_actions)
	_update_minimum_height_of(_actions_container)
	_update_minimum_height_of(_container, 16)
	custom_minimum_size.y = _container.custom_minimum_size.y + 64


func _update_minimum_height_of(control: Control, spacing_px: int = 4) -> void:
	var minimum_height: float = 0

	var number_of_controls: int = 0
	for child in control.get_children():
		if not child is Control:
			continue
		var child_control := child as Control
		if not child_control.visible:
			continue
		number_of_controls += 1
		minimum_height += child_control.custom_minimum_size.y

	# Take node spacing into account
	if number_of_controls > 1:
		minimum_height += (number_of_controls - 1) * spacing_px

	control.custom_minimum_size.y = minimum_height


func _populate_relationship_info_bool(
		info_node: RelationshipInfoNode, value: bool, reverse_value: bool
) -> void:
	info_node.country_1 = country_1
	info_node.country_2 = country_2
	info_node.info_text_1_to_2 = "Yes" if value else "No"
	info_node.info_color_1_to_2 = Color.GREEN if value else Color.RED
	info_node.info_text_2_to_1 = "Yes" if reverse_value else "No"
	info_node.info_color_2_to_1 = Color.GREEN if reverse_value else Color.RED


func _refresh_info() -> void:
	if not is_node_ready():
		return

	if country_1 == null or country_2 == null:
		return

	var relationship: DiplomacyRelationship = (
			country_1.relationships.with_country(country_2)
	)
	var reverse_relationship: DiplomacyRelationship = (
			country_2.relationships.with_country(country_1)
	)

	if game != null and game.rules.is_diplomacy_presets_enabled():
		_preset.country_1 = country_1
		_preset.country_2 = country_2
		_preset.info_text_1_to_2 = relationship.preset().name
		_preset.info_color_1_to_2 = relationship.preset().color
		_preset.info_text_2_to_1 = reverse_relationship.preset().name
		_preset.info_color_2_to_1 = reverse_relationship.preset().color
		_preset.show()
	else:
		_preset.hide()

	_populate_relationship_info_bool(
			_grants_military_access_info,
			relationship.grants_military_access(),
			reverse_relationship.grants_military_access()
	)
	_populate_relationship_info_bool(
			_is_trespassing_info,
			relationship.is_trespassing(),
			reverse_relationship.is_trespassing()
	)
	_populate_relationship_info_bool(
			_is_fighting_info,
			relationship.is_fighting(),
			reverse_relationship.is_fighting()
	)

	_connect_relationship_signals(relationship)
	_connect_relationship_signals(reverse_relationship)


## Note that if the node is ready,
## this automatically updates the custom minimum height.
func _refresh_available_actions() -> void:
	if not is_node_ready():
		return

	NodeUtils.delete_all_children(_available_actions)
	_actions_container.hide()

	if country_1 == null or country_2 == null or game == null:
		_update_minimum_height()
		return

	var playing_country: Country = game.turn.playing_player().playing_country
	if not (
			playing_country in [country_1, country_2]
			and MultiplayerUtils.has_gameplay_authority(
					multiplayer, game.turn.playing_player()
			)
	):
		_update_minimum_height()
		return

	var relationship: DiplomacyRelationship = (
			country_1.relationships.with_country(country_2)
			if playing_country == country_1 else
			country_2.relationships.with_country(country_1)
	)

	for action in relationship.available_actions():
		var diplomacy_action_button := (
				diplomacy_action_button_scene.instantiate()
				as DiplomacyActionButton
		)
		diplomacy_action_button.diplomacy_action = action
		diplomacy_action_button.game = game
		diplomacy_action_button.pressed.connect(
				_on_diplomacy_action_button_pressed
		)
		_available_actions.add_child(diplomacy_action_button)
		_actions_container.show()

	_update_minimum_height()


func _on_diplomacy_action_button_pressed(
		diplomacy_action: DiplomacyAction
) -> void:
	if country_1 == null or country_2 == null or game == null:
		return

	var playing_country: Country = game.turn.playing_player().playing_country
	if playing_country == country_1:
		diplomacy_action_pressed.emit(diplomacy_action, country_2)
	elif playing_country == country_2:
		diplomacy_action_pressed.emit(diplomacy_action, country_1)
	else:
		push_warning(
				"Pressed on a diplomatic action, but"
				+ " the user is not playing as either country."
		)


func _on_relationship_data_changed(_relation: DiplomacyRelationship) -> void:
	# TODO this is inefficient
	# because it'll refresh the whole thing
	# every time an individual piece of info changes
	_refresh_info()


func _on_available_actions_changed(_relation: DiplomacyRelationship) -> void:
	_refresh_available_actions()
