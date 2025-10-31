class_name WorldVisuals2D
extends Node2D

signal overlay_created(node: Node)

# TODO Temporary... Figure out how to not need this
var project: GameProject

var world: GameWorld:
	set(value):
		world = value
		province_selection = ProvinceSelection.new(world.provinces)
		_initialize()

## Automatically initialized when providing the [GameWorld].
var province_selection: ProvinceSelection

var _is_decorations_visible: bool = true

@onready var _background_color := %BackgroundColor as BackgroundColor
@onready var map_mode_setup := %MapModeSetup as MapModeSetup
@onready var _army_visuals_setup := %ArmyVisualsSetup as ArmyVisualsSetup
@onready var _auto_arrow_input := %AutoArrowInput as AutoArrowInput
@onready var background := %Background as WorldBackground
@onready var province_visuals := %Provinces as ProvinceVisualsContainer2D
@onready var _decorations_node := %Decorations as WorldDecorationsNode
@onready var _auto_arrow_container := %AutoArrows as AutoArrowContainer


func _ready() -> void:
	_initialize()


func _initialize() -> void:
	if not is_node_ready() or project == null or world == null:
		return

	var playing_country := PlayingCountry.new(project.game.turn)

	# We need to setup the provinces first
	province_visuals.setup(world.provinces)

	_background_color.world = world

	map_mode_setup.overlay_created.connect(overlay_created.emit)
	map_mode_setup.setup(self)

	_army_visuals_setup.setup(world.armies, playing_country)

	_auto_arrow_input.game = project.game

	_decorations_node.world_decorations = world.decorations
	_update_decoration_visibility()

	_auto_arrow_container.setup(project.game.countries)


## Shows or hides the decorations.
func set_decoration_visiblity(is_decorations_visible: bool) -> void:
	_is_decorations_visible = is_decorations_visible
	_update_decoration_visibility()


func _update_decoration_visibility() -> void:
	if _decorations_node == null:
		return
	_decorations_node.visible = _is_decorations_visible
