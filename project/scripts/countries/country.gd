class_name Country
extends Resource
## Represents a political entity. It is called "country", but in truth,
## this can represent any political entity, even those who do not
## have control over any land.


signal money_changed(new_amount: int)

@export var country_name: String = ""
@export var color: Color = Color.WHITE

## All countries must have a unique id,
## for the purposes of saving/loading and networking.
var id: int = -1

var money: int = 0:
	set(value):
		money = value
		money_changed.emit(money)

var auto_arrows := AutoArrows.new()
