class_name WorldVisuals2D
extends Node2D


var world: GameWorld2D:
	set(value):
		world = value
		_initialize()

# TODO Temporary... Figure out how to not need this
var game: Game

@onready var province_selection := %ProvinceSelection as ProvinceSelection
@onready var province_visuals := %Provinces as ProvinceVisualsContainer2D

@onready var _province_setup := %ProvinceVisualsSetup as ProvinceVisualsSetup
@onready var _army_visuals_setup := %ArmyVisualsSetup as ArmyVisualsSetup
@onready var _auto_arrow_input := %AutoArrowInput as AutoArrowInput
@onready var _auto_arrow_sync := %AutoArrowSync as AutoArrowSync
@onready var _auto_arrows := %AutoArrows as AutoArrowContainer


func _initialize() -> void:
	if not is_node_ready():
		await ready
	
	var playing_country := PlayingCountry.new(game.turn)
	
	_province_setup.provinces = world.provinces
	_army_visuals_setup.playing_country = playing_country
	_army_visuals_setup.armies = world.armies
	_auto_arrow_input.playing_country = playing_country
	_auto_arrow_sync.game = game
	_auto_arrows.playing_country = playing_country
	_auto_arrows.countries = game.countries
