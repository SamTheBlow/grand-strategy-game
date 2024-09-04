class_name IncomeMoney
## Provides information on how much money something generates.
## Extend this class to implement the details.


signal changed(new_value: int)


var _total: int:
	set(value):
		if _total == value:
			return
		
		_total = value
		changed.emit(_total)


func total() -> int:
	return _total
