class_name ProjectVersion
## Provides information about a project version from given [String].
##
## The structure used is: MAJOR.MINOR.PATCHsuffix
## With one dot separating each of the three numbers,
## and with nothing separating the patch number and the suffix.
## Only the major number is required; the other two default to zero.
## The suffix is optional and may contain any character.
## It may even start with a dot or with a digit.
## The suffix will be stripped at its edges (see [method String.strip_edges]).
##
## See the unit tests for examples of valid and invalid strings.

var _is_valid: bool = true
var _major: int
var _minor: int = 0
var _patch: int = 0
var _suffix: String = ""


## Uses the project setting by default if no string is given.
func _init(
		version_string: String = ProjectSettings.get_setting(
				"application/config/version", ""
		)
) -> void:
	var major_string: String = ""
	var i: int = 0
	while i < version_string.length():
		var string_at_index: String = version_string[i]

		if string_at_index not in "1234567890":
			break

		major_string += string_at_index
		i += 1

	if major_string == "":
		# The string doesn't start with a digit. The string is invalid.
		_is_valid = false
		return

	_major = major_string.to_int()

	var index_after_major: int = i
	var minor_string: String = ""
	while i < version_string.length():
		var string_at_index: String = version_string[i]

		if i == index_after_major:
			if string_at_index != ".":
				break
			i += 1
			continue

		if string_at_index not in "1234567890":
			break

		minor_string += string_at_index
		i += 1

	if minor_string == "":
		# There was not a dot followed by a digit.
		# So, there is no minor. The rest of the string is the suffix.
		_suffix = version_string.right(-index_after_major).strip_edges()
		return

	_minor = minor_string.to_int()

	var index_after_minor: int = i
	var patch_string: String = ""
	while i < version_string.length():
		var string_at_index: String = version_string[i]

		if i == index_after_minor:
			if string_at_index != ".":
				break
			i += 1
			continue

		if string_at_index not in "1234567890":
			break

		patch_string += string_at_index
		i += 1

	if patch_string == "":
		# There was not a dot followed by a digit.
		# So, there is no patch. The rest of the string is the suffix.
		_suffix = version_string.right(-index_after_minor).strip_edges()
		return

	_patch = patch_string.to_int()
	_suffix = version_string.right(-i).strip_edges()


## Returns true if given string was a valid project version.
func is_valid() -> bool:
	return _is_valid


func major() -> int:
	return _major


func minor() -> int:
	return _minor


func patch() -> int:
	return _patch


func suffix() -> String:
	return _suffix


static func _unit_test() -> void:
	var valid_cases: Array[String] = [
		"4", "4.2", "4.2.0", "46.250.017", "4.2.0f", "4.2.1.1", "4.2.0 dev",
		"4.2dev", "4.2a0", "4.2 dev", "4.2💀", "4.2.0 1221", "4.", "4.2 .0",
		"4. 2", "4.2.lol", "4.a.0", "4a.2.0", "4 2", "4,2", "4.2\r\n"
	]
	for valid_case in valid_cases:
		assert(ProjectVersion.new(valid_case).is_valid())

	var invalid_cases: Array[String] = [
		"", "dev4.2", ".2.0", "-4", "i like mashed potatoes", "inf", " 4.2.0"
	]
	for invalid_case in invalid_cases:
		assert(not ProjectVersion.new(invalid_case).is_valid())

	var case_1 := ProjectVersion.new("4\t.")
	assert(
			case_1.is_valid()
			and case_1.major() == 4
			and case_1.minor() == 0
			and case_1.patch() == 0
			and case_1.suffix() == "."
	)

	var case_2 := ProjectVersion.new("4..2. . ")
	assert(
			case_2.is_valid()
			and case_2.major() == 4
			and case_2.minor() == 0
			and case_2.patch() == 0
			and case_2.suffix() == "..2. ."
	)

	var case_3 := ProjectVersion.new("4.02. 💀\r")
	assert(
			case_3.is_valid()
			and case_3.major() == 4
			and case_3.minor() == 2
			and case_3.patch() == 0
			and case_3.suffix() == ". 💀"
	)

	var case_4 := ProjectVersion.new("00999.6666.17.099.5 dev")
	assert(
			case_4.is_valid()
			and case_4.major() == 999
			and case_4.minor() == 6666
			and case_4.patch() == 17
			and case_4.suffix() == ".099.5 dev"
	)

	var case_5 := ProjectVersion.new("4.2.1-branch-add-watermelons")
	assert(
			case_5.is_valid()
			and case_5.major() == 4
			and case_5.minor() == 2
			and case_5.patch() == 1
			and case_5.suffix() == "-branch-add-watermelons"
	)

	var case_6 := ProjectVersion.new("4.2    lots  of  spaces ")
	assert(
			case_6.is_valid()
			and case_6.major() == 4
			and case_6.minor() == 2
			and case_6.patch() == 0
			and case_6.suffix() == "lots  of  spaces"
	)
