class_name PlayerSelectPopup
extends VBoxContainer
## Popup that allows the user to select a [GamePlayer] from given list.
##
## See also: [GamePopup]

signal player_selected(game_player: GamePlayer)
signal invalidated()

@onready var _game_player_list := %GamePlayerList as GamePlayerListNode


func setup(game_players: GamePlayers) -> void:
	if not is_node_ready():
		await ready

	_game_player_list.setup(game_players)
	_game_player_list.game_player_selected.connect(player_selected.emit)
	_game_player_list.game_player_selected.connect(invalidated.emit.unbind(1))


func buttons() -> Array[String]:
	return ["Cancel"]
