class_name Country
extends Node


@export var country_name: String = "(Unnamed Country)"
@export var color: Color = Color.WHITE

var id: int = -1


func equals(country: Country) -> bool:
	return (
			id == country.id
			and country_name == country.country_name
			and color.is_equal_approx(country.color)
	)


static func from_JSON(json_data: Dictionary) -> Country:
	var country := Country.new()
	country.id = json_data["id"]
	country.country_name = json_data["country_name"]
	country.color = Color(json_data["color"])
	country.name = str(country.id)
	return country


func as_JSON() -> Dictionary:
	return {
		"id": id,
		"country_name": country_name,
		"color": color.to_html(),
	}
