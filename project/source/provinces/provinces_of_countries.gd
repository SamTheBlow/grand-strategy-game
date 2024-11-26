class_name ProvincesOfCountries
## Keeps track of which provinces each [Country] controls.


## Dictionary[Country, ProvincesOfCountry]
var list: Dictionary = {}


func _init(provinces: Provinces) -> void:
	provinces.added.connect(_on_province_added)
	for province in provinces.list():
		province.owner_changed.connect(_on_province_owner_changed)
		_add_to_list(province)


func _add_to_list(province: Province) -> void:
	if not list.has(province.owner_country):
		list[province.owner_country] = ProvincesOfCountry.new()

	list[province.owner_country].add(province)


func _on_province_owner_changed(province: Province) -> void:
	_add_to_list(province)


func _on_province_added(province: Province) -> void:
	_add_to_list(province)
