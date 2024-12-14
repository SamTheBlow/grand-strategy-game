class_name ProvincesOfCountry
## Provides a list of which provinces are under control of
## one specific [Country].
## Removes provinces from the list when their owner changes,
## but does not add provinces on its own.
##
## See also: [ProvincesOfEachCountry]

## Do not directly manipulate this list! Use add() instead.
var list: Array[Province] = []


func add(province: Province) -> void:
	list.append(province)
	province.owner_changed.connect(_on_province_owner_changed)


func _on_province_owner_changed(province: Province) -> void:
	province.owner_changed.disconnect(_on_province_owner_changed)
	list.erase(province)
