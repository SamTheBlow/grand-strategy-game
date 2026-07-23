class_name ModifierRequest
## Class responsible for requesting a game's modifiers.
##
## Explanation:
## To request modifiers, you use the modifiers() method.
## This method emits a signal. Objects that add modifiers to the game
## need to be connected beforehand using add_provider().
## The signal sends a reference to an array of modifiers.
## When they receive the signal, objects can add modifiers by appending
## their modifiers to the array. The signal also passes a ModifierContext
## object that gives information about why modifiers are being requested.

signal modifiers_requested(array: Array[Modifier], context: ModifierContext)

const _REQUEST_METHOD_NAME: String = "_on_modifiers_requested"


func modifiers(context: ModifierContext) -> ModifierList:
	var array: Array[Modifier] = []
	modifiers_requested.emit(array, context)
	return ModifierList.new(array)


## The given object will be able to add modifiers to the game.
## The object must have the method that provides modifiers.
func add_provider(object: Object) -> void:
	if not object.has_method(_REQUEST_METHOD_NAME):
		push_warning(
				"Tried to add a modifier provider that "
				+ "doesn't have method \"" + _REQUEST_METHOD_NAME + "\"."
		)
		return

	modifiers_requested.connect(Callable(object, _REQUEST_METHOD_NAME))


func remove_provider(object: Object) -> void:
	modifiers_requested.disconnect(Callable(object, _REQUEST_METHOD_NAME))
