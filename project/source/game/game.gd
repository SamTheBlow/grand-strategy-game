class_name Game
## The game.
## There are so many things to setup, there are entire classes
## dedicated to loading the game (see [LoadGame], [GameFromRawDict]...).
## Doing the setup manually yourself is not recommended.
##
## This class is very bloated.
## It's typical for a class to store the game in their properties
## just to access other classes in the game.


signal game_started()
signal game_over(winning_country: Country)

## Must setup before the game starts.
## You are not meant to edit the rules once they are set.
var rules: GameRules:
	set(value):
		rules = value
		rules.battle.battle_algorithm_option = (
				rules.battle_algorithm_option.selected
		)
		rules.battle.modifier_request = modifier_request
		_setup_global_modifiers()

## Must setup before the game starts.
## All of the [Country] objects used in this game should be listed in here.
var countries := Countries.new()

## Must setup before the game starts.
## This list must not be empty.
var game_players: GamePlayers

## Must setup before the game starts.
var turn: GameTurn

var world: GameWorld

## The game's RNG.
## It's important to always use this instead of built-in RNG methods
## so that RNG stays the same when you reload the game and when you play online.
var rng := RandomNumberGenerator.new()

## Use this to obtain or provide modifiers across the entire game.
var modifier_request := ModifierRequest.new()

# TODO bad code: this has nothing to do with game logic.
# The culprit: [GameNotification] shouldn't have an icon property.
var offer_accepted_icon: Texture2D

## The user is allowed to continue playing after the game "ends".
var _game_over: bool = false

## Keys are a modifier context (String); values are a [Modifier].
## This property is setup automatically when loading in the game rules.
var _global_modifiers: Dictionary = {}

## Objects which we never need to access.
## These are stored here only because they need to stay referenced.
var _components: Array = []


func _init() -> void:
	modifier_request.add_provider(self)


## Call this when you're ready to start the game loop.
func start() -> void:
	if rules.turn_limit_enabled.value:
		var turn_limit := TurnLimit.new()
		turn_limit.final_turn = rules.turn_limit.value
		turn.turn_changed.connect(turn_limit._on_new_turn)
		turn_limit.game_over.connect(_on_game_over)
		_components.append(turn_limit)
	
	var province_control_goal := ProvinceControlGoal.new()
	province_control_goal.game = self
	turn.turn_changed.connect(province_control_goal._on_new_turn)
	province_control_goal.game_over.connect(_on_game_over)
	_components.append(province_control_goal)
	
	_components.append_array([
		MilitaryAccessLossBehavior.new(self),
		DiplomacyRelationshipAutoChanges.new(self),
		AutoEndTurn.new(self),
		BattleDetection.new(world.armies, rules.battle),
	])
	
	rules.lock()
	game_started.emit()
	turn.loop()


## Initializes the [member Game.turn].
## The [member Game.rules] must be setup beforehand.
func setup_turn(starting_turn: int = 1, playing_player_index: int = 0) -> void:
	turn = GameTurn.new()
	turn.game = self
	turn._turn = starting_turn
	turn._playing_player_index = playing_player_index


## Builds this game's global [Modifier]s according to the [GameRules].
## Call this when the [GameRules] are set.
func _setup_global_modifiers() -> void:
	_global_modifiers = {}
	if rules.global_attacker_efficiency.value != 1.0:
		_global_modifiers["attacker_efficiency"] = (
				ModifierMultiplier.new(
						"Base Modifier",
						"Attackers all have this modifier by default.",
						rules.global_attacker_efficiency.value
				)
		)
	if rules.global_defender_efficiency.value != 1.0:
		_global_modifiers["defender_efficiency"] = (
				ModifierMultiplier.new(
						"Base Modifier",
						"Defenders all have this modifier by default.",
						rules.global_defender_efficiency.value
				)
		)


## Used to determine the winner when the game ends.
func _winning_country() -> Country:
	# Get how many provinces each country has
	var ownership: Array = world.provinces.province_count_per_country()
	
	# Find which player has the most provinces
	var winning_player_index: int = 0
	var number_of_players: int = ownership.size()
	for i in number_of_players:
		if ownership[i][1] > ownership[winning_player_index][1]:
			winning_player_index = i
	
	return ownership[winning_player_index][0]


func _on_game_over() -> void:
	if _game_over:
		return
	
	_game_over = true
	var winning_country: Country = _winning_country()
	game_over.emit(winning_country)


## This object is itself a provider for the [ModifierRequest] system.
## It provides the game's global [Modifier]s.
func _on_modifiers_requested(
		modifiers_: Array[Modifier],
		context: ModifierContext
) -> void:
	if _global_modifiers.has(context.context()):
		modifiers_.append(_global_modifiers[context.context()])
