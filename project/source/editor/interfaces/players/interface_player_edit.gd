class_name InterfacePlayerEdit
extends AppEditorInterface
## Interface for editing given [GamePlayer].

signal closed()
signal delete_pressed(game_player: GamePlayer)
signal duplicate_pressed(game_player: GamePlayer)

var game_player := GamePlayer.new()

## This interface automatically closes
## if its player is removed from this players list.
## May be null, in which case this feature is not used.
var game_players: GamePlayers = null:
	set(value):
		if game_players != null:
			game_players.player_removed.disconnect(_on_player_removed)

		game_players = value

		if game_players != null:
			game_players.player_removed.connect(_on_player_removed)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"delete"):
		delete_pressed.emit(game_player)
	if Input.is_action_just_pressed(&"duplicate"):
		duplicate_pressed.emit(game_player)


func _on_back_button_pressed() -> void:
	closed.emit()


func _on_player_removed(player_removed: GamePlayer) -> void:
	if player_removed == game_player:
		closed.emit()


func _on_delete_button_pressed() -> void:
	delete_pressed.emit(game_player)
