class_name AIThread
## Runs a [PlayerAI] in a separate thread.
## Emits a signal when finished.
# WARNING The way this class works really depends on the assumption that
# the game state never changes while it's the AI's turn.
# If it did, then we'd likely have to use [Mutex] and [Semaphore].


signal finished(actions: Array[Action])

var _thread := Thread.new()


## Starts the other thread.
## Pushes an error if the other thread is already running.
func run(game: Game, player: GamePlayer, ai: PlayerAI) -> void:
	if is_running():
		push_error("Tried to run an AI thread, but it is already running.")
		return

	if _thread.is_started():
		_thread.wait_to_finish()

	# If you want to run the AI in the main thread for debugging,
	# just uncomment this line and comment out the other one.
	#_thread_function(ai, game, player)
	_thread.start(_thread_function.bind(ai, game, player))


## Returns true if an AI is currently running.
func is_running() -> bool:
	return _thread != null and _thread.is_alive()


## The other thread runs the AI logic and sends the result to the main thread.
func _thread_function(ai: PlayerAI, game: Game, player: GamePlayer) -> void:
	_receive_ai_actions.call_deferred(ai.actions(game, player))


## The main thread receives the AI actions from the other thread.
func _receive_ai_actions(actions: Array[Action]) -> void:
	finished.emit(actions)
