class_name ProvincesOfCountry


## Do not directly manipulate this list! Use add() instead.
var list: Array[Province] = []


func add(province: Province) -> void:
	list.append(province)
	province.owner_changed.connect(_on_province_owner_changed)


func _on_province_owner_changed(province: Province) -> void:
	province.owner_changed.disconnect(_on_province_owner_changed)
	list.erase(province)
