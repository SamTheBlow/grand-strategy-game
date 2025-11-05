class_name MapModeSetup
extends Node
## Applies a map mode to the world.

signal overlay_created(node: Node)

enum MapMode {
	POLITICAL,
	EDITOR_ADJACENCY,
	EDITOR_COUNTRY,
}

var _is_setup: bool = false
var _world_visuals: WorldVisuals2D

var _current_map_mode := MapMode.POLITICAL
var _arrow_behavior: ArrowBehavior = ArrowBehaviorNone.new():
	set(value):
		_arrow_behavior = value
		_arrow_behavior.start(
				%AutoArrowInput as AutoArrowInput,
				%AutoArrows as AutoArrowContainer
		)

@onready var _node_political := %Political as MapModePolitical
@onready var _node_editor_adj := %EditorAdjacency as MapModeEditorAdjacency
@onready var _node_editor_country := %EditorCountry as MapModeEditorCountry


func _ready() -> void:
	_node_editor_adj.overlay_created.connect(overlay_created.emit)
	if _is_setup:
		_update()


func setup(world_visuals: WorldVisuals2D) -> void:
	_world_visuals = world_visuals
	_is_setup = true

	if is_node_ready():
		_update()


func set_map_mode(map_mode: MapMode) -> void:
	if _current_map_mode == map_mode:
		return

	if not (_is_setup and is_node_ready()):
		_current_map_mode = map_mode
		return

	match _current_map_mode:
		MapMode.POLITICAL:
			_node_political.is_enabled = false
		MapMode.EDITOR_ADJACENCY:
			_node_editor_adj.is_enabled = false
		MapMode.EDITOR_COUNTRY:
			_node_editor_country.is_enabled = false
			_world_visuals.province_selection.is_disabled = false
		_:
			_node_political.is_enabled = false

	_current_map_mode = map_mode
	_enable_map_mode()


## Use this to specify a country.
func set_map_mode_editor_country(country: Country) -> void:
	_node_editor_country.setup(country)
	set_map_mode(MapMode.EDITOR_COUNTRY)
	_arrow_behavior = ArrowBehaviorSpecificCountry.new(country.id)


func _update() -> void:
	_node_political.setup(
			_world_visuals.world.armies,
			_world_visuals.world.provinces,
			PlayingCountry.new(_world_visuals.project.game.turn),
			_world_visuals.world.armies_in_each_province,
			_world_visuals.province_selection
	)
	_node_editor_adj.setup(
			_world_visuals.province_selection,
			PolygonEditEdgeCase.new(_world_visuals.world)
	)

	_enable_map_mode()


func _enable_map_mode() -> void:
	match _current_map_mode:
		MapMode.POLITICAL:
			_node_political.is_enabled = true
		MapMode.EDITOR_ADJACENCY:
			_node_editor_adj.is_enabled = true
		MapMode.EDITOR_COUNTRY:
			_world_visuals.province_selection.is_disabled = true
			_node_editor_country.is_enabled = true
		_:
			push_error("Unrecognized map mode.")
			_node_political.is_enabled = true

	if _current_map_mode != MapMode.EDITOR_COUNTRY:
		_arrow_behavior = ArrowBehaviorOngoingGame.new(
				_world_visuals.project.game,
				multiplayer,
				_world_visuals.province_selection
		)


@abstract class ArrowBehavior:
	@abstract func start(
			input: AutoArrowInput, container: AutoArrowContainer
	) -> void


class ArrowBehaviorOngoingGame extends ArrowBehavior:
	var _game: Game
	var _multiplayer: MultiplayerAPI
	var _province_selection: ProvinceSelection

	var _playing_country: PlayingCountry
	var _input: AutoArrowInput
	var _container: AutoArrowContainer

	func _init(
			game: Game,
			multiplayer: MultiplayerAPI,
			province_selection: ProvinceSelection
	) -> void:
		_game = game
		_multiplayer = multiplayer
		_province_selection = province_selection

	func start(
			input: AutoArrowInput, container: AutoArrowContainer
	) -> void:
		_playing_country = PlayingCountry.new(_game.turn)
		_input = input
		_container = container

		# Initialize
		_container.visible = _province_selection.selected_province() != null
		_update_country()

		# Connect signals for automatic updates
		_province_selection.selected_province_changed.connect(
				func(province: Province) -> void:
					_container.visible = province != null
		)
		_playing_country.changed.connect(
				func(_country: Country) -> void:
					_update_country()
		)

	func _update_country() -> void:
		var country_id: int = _current_country_id()
		_input.country_to_edit_id = country_id
		_container.show_country(country_id)

	## Returns the playing country's id only when you control it.
	func _current_country_id() -> int:
		if not _game.turn.is_running():
			return -1

		if _game.game_players.you_control_country(
				_multiplayer, _playing_country.country()
		):
			return _playing_country.country().id

		return -1


class ArrowBehaviorNone extends ArrowBehavior:
	func start(_input: AutoArrowInput, _container: AutoArrowContainer) -> void:
		pass


class ArrowBehaviorSpecificCountry extends ArrowBehavior:
	var _country_id: int

	func _init(country_id: int) -> void:
		_country_id = country_id

	func start(input: AutoArrowInput, container: AutoArrowContainer) -> void:
		input.country_to_edit_id = _country_id
		container.show()
		container.show_country(_country_id)
