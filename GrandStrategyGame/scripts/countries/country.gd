class_name Country
extends Resource


signal money_changed(new_amount: int)

@export var country_name: String = ""
@export var color: Color = Color.WHITE

var id: int = -1

var money: int = 0 : set = set_money


func set_money(value: int) -> void:
	money = value
	money_changed.emit(money)
