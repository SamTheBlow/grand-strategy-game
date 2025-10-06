class_name WorldVisuals2D
extends Node2D

var world: GameWorld:
	set(value):
		world = value
		_initialize()

# TODO Temporary... Figure out how to not need this
var game: Game

var _is_decorations_visible: bool = true

@onready var province_selection := %ProvinceSelection as ProvinceSelection
@onready var province_visuals := %Provinces as ProvinceVisualsContainer2D

@onready var _province_setup := %ProvinceVisualsSetup as ProvinceVisualsSetup
@onready var _province_highlight := %ProvinceHighlight as ProvinceHighlight
@onready var _army_visuals_setup := %ArmyVisualsSetup as ArmyVisualsSetup

@onready var _decorations_node := %Decorations as WorldDecorationsNode

@onready var _auto_arrow_input := %AutoArrowInput as AutoArrowInput
@onready var _auto_arrows := %AutoArrows as AutoArrowContainer


func _ready() -> void:
	_initialize()


func _initialize() -> void:
	if not is_node_ready() or world == null:
		return

	var playing_country := PlayingCountry.new(game.turn)

	_province_setup.provinces = world.provinces
	_province_highlight.armies = world.armies
	_province_highlight.playing_country = playing_country
	_province_highlight.armies_in_each_province = (
			world.armies_in_each_province
	)
	_army_visuals_setup.playing_country = playing_country
	_army_visuals_setup.armies = world.armies
	_decorations_node.world_decorations = world.decorations
	_update_decoration_visibility()
	_auto_arrow_input.game = game
	_auto_arrows.playing_country = playing_country
	_auto_arrows.countries = game.countries


## Shows or hides the decorations.
func set_decoration_visiblity(is_decorations_visible: bool) -> void:
	_is_decorations_visible = is_decorations_visible
	_update_decoration_visibility()


func _update_decoration_visibility() -> void:
	if _decorations_node == null:
		return
	_decorations_node.visible = _is_decorations_visible
