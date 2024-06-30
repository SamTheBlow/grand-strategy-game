class_name Country
extends Resource
## Represents a political entity. It is called "country", but in truth,
## this can represent any political entity, even those who do not
## have control over any land.


signal money_changed(new_amount: int)

## All countries must have a unique id
## for the purposes of saving/loading/syncing.
var id: int = -1

@export var country_name: String = ""
@export var color: Color = Color.WHITE

var money: int = 0:
	set(value):
		money = value
		money_changed.emit(money)

var auto_arrows := AutoArrows.new()


## Returns true if this country's armies have the
## diplomatic permission to move into given country's provinces.
func can_move_into_country(_country: Country) -> bool:
	return true
