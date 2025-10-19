class_name ProvincesOfCountry
## Provides a list of which provinces are under control of
## one specific [Country].
## Removes provinces from the list when their owner changes,
## but does not add provinces on its own.
##
## See also: [ProvincesOfEachCountry]

## Do not directly manipulate this list! Use add() and remove() instead.
var list: Array[Province] = []


func add(province: Province) -> void:
	if list.has(province):
		push_warning("Province is already in the list.")
		return
	list.append(province)
	province.owner_changed.connect(remove)


func remove(province: Province) -> void:
	if not list.has(province):
		push_warning("Province is not in the list.")
		return
	list.erase(province)
	province.owner_changed.disconnect(remove)
