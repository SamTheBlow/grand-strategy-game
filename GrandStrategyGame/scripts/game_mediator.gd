class_name GameMediator
## This class mediates communication between a game's objects.


var _modifier_mediator: ModifierMediator


func _init(game: Node) -> void:
	_modifier_mediator = ModifierMediator.new(game)


func modifier_mediator() -> ModifierMediator:
	return _modifier_mediator
