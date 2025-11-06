class_name BuildFortressButton
extends Button
## Automatically disables itself when given player
## is unable to build a fortress in given province.
## (Or if given data is null.)
##
## See also: [RecruitButton], [ComponentUI]
# TODO this code looks a lot like the code for [RecruitButton]

## May be null.
var game: Game = null:
	set(value):
		if game == value:
			return
		game = value
		_setup_build_conditions()
		_update_is_disabled()

## May be null.
var province: Province = null:
	set(value):
		if province == value:
			return
		province = value
		_setup_build_conditions()
		_update_is_disabled()

## May be null.
var player: GamePlayer = null:
	set(value):
		if player == value:
			return

		# Disconnect signals
		if player != null:
			player.playing_country_changed.disconnect(
					_on_playing_country_changed
			)

		player = value

		# Connect signals
		if player != null:
			player.playing_country_changed.connect(
					_on_playing_country_changed
			)

		_setup_build_conditions()
		_update_is_disabled()

## May be null.
var _fortress_build_conditions: FortressBuildConditions = null:
	set(value):
		if _fortress_build_conditions == value:
			return

		# Disconnect signals
		if _fortress_build_conditions != null:
			_fortress_build_conditions.can_build_changed.disconnect(
					_on_fortress_can_build_changed
			)

		_fortress_build_conditions = value

		# Connect signals
		if _fortress_build_conditions != null:
			_fortress_build_conditions.can_build_changed.connect(
					_on_fortress_can_build_changed
			)


func _ready() -> void:
	_update_is_disabled()


func _setup_build_conditions() -> void:
	if (
			game == null
			or province == null
			or player == null
			or player.playing_country == null
	):
		_fortress_build_conditions = null
		return

	_fortress_build_conditions = (
			FortressBuildConditions.new(player.playing_country, province, game)
	)


func _update_is_disabled() -> void:
	if not is_node_ready():
		return

	disabled = (
			_fortress_build_conditions == null
			or not MultiplayerUtils.has_gameplay_authority(multiplayer, player)
			or not _fortress_build_conditions.can_build()
	)


func _on_fortress_can_build_changed(_can_build: bool) -> void:
	_update_is_disabled()


func _on_playing_country_changed() -> void:
	_setup_build_conditions()
