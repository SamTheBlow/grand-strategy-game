class_name BuildFortressButton
extends Button
## Automatically disables itself when given player
## is unable to build a fortress in given province.
## Also disables itself if either the province or the player is null.
##
## See also: [RecruitButton], [ComponentUI]
# TODO this code looks a lot like the code for [RecruitButton]


var province: Province:
	set(value):
		if province == value:
			return
		province = value
		_setup_build_conditions()
		_refresh_is_disabled()

var player: GamePlayer:
	set(value):
		if player == value:
			return
		player = value
		_setup_build_conditions()
		_refresh_is_disabled()

var game: Game:
	set(value):
		if game == value:
			return
		game = value
		_setup_build_conditions()
		_refresh_is_disabled()

var _fortress_build_conditions: FortressBuildConditions:
	set(value):
		if _fortress_build_conditions == value:
			return
		_disconnect_signals()
		_fortress_build_conditions = value
		_connect_signals()


func _ready() -> void:
	_refresh_is_disabled()


func _setup_build_conditions() -> void:
	if province == null or player == null or game == null:
		_fortress_build_conditions = null
		return
	
	_fortress_build_conditions = (
			FortressBuildConditions.new(player.playing_country, province, game)
	)


func _refresh_is_disabled() -> void:
	if not is_node_ready():
		return
	
	if player == null or _fortress_build_conditions == null:
		disabled = true
		return
	
	disabled = not (
			MultiplayerUtils.has_gameplay_authority(multiplayer, player)
			and _fortress_build_conditions.can_build()
	)


func _connect_signals() -> void:
	if _fortress_build_conditions == null:
		return
	
	if not (
			_fortress_build_conditions.can_build_changed
			.is_connected(_on_fortress_can_build_changed)
	):
		_fortress_build_conditions.can_build_changed.connect(
				_on_fortress_can_build_changed
		)


func _disconnect_signals() -> void:
	if _fortress_build_conditions == null:
		return
	
	if (
			_fortress_build_conditions.can_build_changed
			.is_connected(_on_fortress_can_build_changed)
	):
		_fortress_build_conditions.can_build_changed.disconnect(
				_on_fortress_can_build_changed
		)


func _on_fortress_can_build_changed(_can_build: bool) -> void:
	_refresh_is_disabled()
