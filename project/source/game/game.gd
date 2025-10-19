class_name Game
## The internal state of a game.

signal error_triggered(error_message: String)
signal game_started()
signal game_over(winning_country: Country)
signal action_applied(action: Action)

## Note: the game's rules must not change after the game started.
var rules: GameRules:
	set(value):
		if rules == value:
			return

		rules = value
		rules.battle.battle_algorithm_option = (
				rules.battle_algorithm_option.selected_value()
		)
		rules.battle.modifier_request = modifier_request

## Be careful: you must include all of the game's countries on this list.
## Do not overwrite!
var countries := Countries.new()

var game_players := GamePlayers.new()

## You must initialize the "rules" property before you initialize this one.
var turn: GameTurn

## Do not overwrite!
var world := GameWorld.new(self)

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
var _global_modifiers: Dictionary = {}

## Objects which we never need to access.
## These are stored here only because they need to stay referenced.
var _components: Array = []


func _init() -> void:
	# We initialize it here so that it calls the setter function
	if rules == null:
		rules = GameRules.new()

	# We initialize it here because we need to initialize the rules first
	if turn == null:
		turn = GameTurn.new(self)

	modifier_request.add_provider(self)

	_components.append_array([
		AutoArrowProvinceReaction.new(self),
		ArmyReinforcements.new(self),
		IncomeEachTurn.new(self),
		ProvinceOwnershipUpdate.new(self),
	])


## Call this when you're ready to start the game loop.
func start() -> void:
	# Can't start a game with 0 players.
	if game_players.size() == 0:
		error_triggered.emit("Cannot start a game with 0 players.")
		return

	rules.lock()
	_setup_global_modifiers()

	if rules.turn_limit_enabled.value:
		var turn_limit := TurnLimit.new()
		turn_limit.final_turn = rules.turn_limit.value
		# TODO bad code: private function
		turn.turn_changed.connect(turn_limit._on_new_turn)
		turn_limit.game_over.connect(_on_game_over)
		_components.append(turn_limit)

	var province_control_goal := ProvinceControlGoal.new(self)
	province_control_goal.game_over.connect(_on_game_over)
	_components.append(province_control_goal)

	_components.append_array([
		MilitaryAccessLossBehavior.new(self),
		DiplomacyRelationshipAutoChanges.new(self),
		AutoEndTurn.new(self),
		BattleDetection.new(
				world.armies, world.armies_in_each_province, rules.battle
		),
	])

	turn.is_running_changed.connect(_on_is_running_changed)
	turn.start()


func apply_action(action: Action) -> void:
	action.apply_to(self, turn.playing_player())
	action_applied.emit(action)


## Builds the game's global [Modifier]s according to the [GameRules].
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
## Currently returns the country that controls the most provinces.
func _winning_country() -> Country:
	# Count how many provinces each country has
	var pcpc := ProvinceCountPerCountry.new()
	pcpc.calculate(world.provinces.list())

	# Determine which country controls the most provinces
	var winning_player_index: int = 0
	for i in pcpc.countries.size():
		if (
				pcpc.number_of_provinces[i]
				> pcpc.number_of_provinces[winning_player_index]
		):
			winning_player_index = i

	return pcpc.countries[winning_player_index]


func _on_is_running_changed(is_running: bool) -> void:
	if is_running:
		game_started.emit()


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
