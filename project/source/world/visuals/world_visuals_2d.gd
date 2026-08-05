class_name WorldVisuals2D
extends Node2D

## Setting this sets everything else automatically.
var project: GameProject:
	set(value):
		project = value
		world = project.game.world
		playing_country = PlayingCountry.new(project.game)
		province_selection = ProvinceSelection.new()
		world.provinces.removed.connect(province_selection.deselect)
		if is_node_ready():
			_setup()

## Automatically initialized when providing the [GameProject].
var world: GameWorld

## Automatically initialized when providing the [GameProject].
var playing_country: PlayingCountry

## Automatically initialized when providing the [GameProject].
var province_selection: ProvinceSelection

## Determines which country's auto-arrows are currently shown.
var _arrow_behavior: ArrowBehavior:
	set(value):
		if _arrow_behavior != null:
			_arrow_behavior.stop()
		_arrow_behavior = value
		_arrow_behavior.start(_auto_arrow_input, _auto_arrow_container)

@onready var _background_color := %BackgroundColor as BackgroundColor
@onready var province_link_highlighter := (
		%ProvinceLinkHighlighter as ProvinceLinkHighlighter
)
@onready var _army_visuals_setup := %ArmyVisualsSetup as ArmyVisualsSetup
@onready var province_input := %ProvinceInput as ProvinceVisualsInput
@onready var _auto_arrow_input := %AutoArrowInput as AutoArrowInput
@onready var background := %Background as WorldBackground
@onready var province_visuals := %Provinces as ProvinceVisualsContainer2D
@onready var _decorations_node := %Decorations as DecorationVisualsContainer2D
@onready var _auto_arrow_container := %AutoArrows as AutoArrowContainer


func _ready() -> void:
	if project != null:
		_setup()


## Shows or hides the decorations.
func set_decoration_visiblity(is_decorations_visible: bool) -> void:
	if is_node_ready():
		_decorations_node.visible = is_decorations_visible
	else:
		ready.connect(
				set_decoration_visiblity.bind(is_decorations_visible),
				ConnectFlags.CONNECT_ONE_SHOT
		)


## Shows the playing country's auto-arrows. This is the default game behavior.
func show_game_arrows() -> void:
	_arrow_behavior = ArrowBehavior.ShowPlayingCountry.new(
			project.game, multiplayer, province_selection, playing_country
	)


## Shows the auto-arrows of given country.
func show_arrows_of_country(country: Country) -> void:
	_arrow_behavior = ArrowBehavior.ShowSpecificCountry.new(country.id)


func _setup() -> void:
	# We need to setup the provinces first
	province_visuals.setup(world.provinces)

	province_input.setup(province_selection)
	province_input.province_unhovered.connect(
			province_link_highlighter.refresh_highlights.unbind(1)
	)

	_background_color.world = world

	province_link_highlighter.setup(
			world.armies,
			world.provinces,
			playing_country,
			world.armies_in_each_province,
			province_selection
	)
	province_link_highlighter.is_enabled = true

	_army_visuals_setup.setup(
			world.armies, playing_country, world.armies_in_each_province
	)

	_auto_arrow_input.game = project.game

	_decorations_node.setup(world.decorations)

	_auto_arrow_container.setup(project.game.countries)
	show_game_arrows()
