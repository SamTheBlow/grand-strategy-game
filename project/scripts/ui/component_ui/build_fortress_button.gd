class_name BuildFortressButton
extends Button
## Automatically disables itself when the playing player
## is unable to build a fortress in given province.
## Also disables itself if either the province or the playing player is null.
##
## See also: [RecruitButton], [ComponentUI]


var province: Province:
	set(value):
		if province == value:
			return
		province = value
		_setup_build_conditions()
		_refresh_is_disabled()

var playing_player: GamePlayer:
	set(value):
		if playing_player == value:
			return
		playing_player = value
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
	if not province or not playing_player:
		_fortress_build_conditions = null
		return
	
	_fortress_build_conditions = FortressBuildConditions.new(
			playing_player.playing_country, province
	)


func _refresh_is_disabled() -> void:
	if not is_node_ready():
		return
	
	if not province or not playing_player or not _fortress_build_conditions:
		disabled = true
		return
	
	disabled = not (
			MultiplayerUtils.has_gameplay_authority(
					multiplayer, playing_player
			)
			and _fortress_build_conditions.can_build()
	)


func _connect_signals() -> void:
	if not _fortress_build_conditions:
		return
	
	if not (
			_fortress_build_conditions.can_build_changed
			.is_connected(_on_fortress_can_build_changed)
	):
		_fortress_build_conditions.can_build_changed.connect(
				_on_fortress_can_build_changed
		)


func _disconnect_signals() -> void:
	if not _fortress_build_conditions:
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
