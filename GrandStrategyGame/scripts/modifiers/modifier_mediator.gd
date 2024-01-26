class_name ModifierMediator
## Class responsible for obtaining certain modifiers from a game.


signal modifiers_requested(array: Array[Modifier], context: ModifierContext)

var _game: Node


func _init(game: Node) -> void:
	_game = game


func modifiers(context: ModifierContext) -> ModifierList:
	var array: Array[Modifier] = []
	modifiers_requested.emit(array, context)
	return ModifierList.new(array)
