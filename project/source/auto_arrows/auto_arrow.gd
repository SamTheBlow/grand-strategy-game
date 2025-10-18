class_name AutoArrow
## Represents a movement from a source province to a destination province.
## This is (kind of) a struct: two autoarrows with the same values
## should be considered the same autoarrow.

const _SOURCE_PROVINCE_ID_KEY = "source_province_id"
const _DEST_PROVINCE_ID_KEY = "destination_province_id"

var _source_province_id: int = -1
var _destination_province_id: int = -1

func _init(
		source_province_id_: int, destination_province_id_: int
) -> void:
	_source_province_id = source_province_id_
	_destination_province_id = destination_province_id_


func source_province_id() -> int:
	return _source_province_id


func destination_province_id() -> int:
	return _destination_province_id


func is_equivalent_to(auto_arrow: AutoArrow) -> bool:
	return (
			_source_province_id >= 0 and _destination_province_id >= 0
			and auto_arrow.source_province_id() == _source_province_id
			and
			auto_arrow.destination_province_id() == _destination_province_id
	)


static func from_raw_data(raw_data: Variant) -> AutoArrow:
	if raw_data is not Dictionary:
		return AutoArrowWithInvalidData.new(raw_data)
	var raw_dict: Dictionary = raw_data

	var new_source_province_id: int = -1
	if ParseUtils.dictionary_has_number(raw_dict, _SOURCE_PROVINCE_ID_KEY):
		new_source_province_id = (
				ParseUtils.dictionary_int(raw_dict, _SOURCE_PROVINCE_ID_KEY)
		)

	var new_destination_province_id: int = -1
	if ParseUtils.dictionary_has_number(raw_dict, _DEST_PROVINCE_ID_KEY):
		new_destination_province_id = (
				ParseUtils.dictionary_int(raw_dict, _DEST_PROVINCE_ID_KEY)
		)

	return AutoArrowWithOtherData.new(
			new_source_province_id, new_destination_province_id, raw_dict
	)


func to_raw_data() -> Variant:
	return _raw_dictionary()


func _raw_dictionary() -> Dictionary:
	var output: Dictionary = {}
	if _source_province_id >= 0:
		output.merge({ _SOURCE_PROVINCE_ID_KEY: _source_province_id })
	if _destination_province_id >= 0:
		output.merge({ _DEST_PROVINCE_ID_KEY: _destination_province_id })
	return output


class AutoArrowWithOtherData extends AutoArrow:
	var _other_data: Dictionary = {}

	func _init(
			source_province_id_: int,
			destination_province_id_: int,
			other_data: Dictionary
	) -> void:
		super(source_province_id_, destination_province_id_)
		_other_data = other_data

	func to_raw_data() -> Variant:
		var output: Dictionary = _other_data.duplicate()
		output.erase(_SOURCE_PROVINCE_ID_KEY)
		output.erase(_DEST_PROVINCE_ID_KEY)
		output.merge(_raw_dictionary())
		return output


class AutoArrowWithInvalidData extends AutoArrow:
	var _data: Variant

	func _init(data: Variant) -> void:
		_data = data

	func to_raw_data() -> Variant:
		return _data
