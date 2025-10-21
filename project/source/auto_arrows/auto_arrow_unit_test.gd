class_name AutoArrowUnitTest
## Mostly tests the raw data parsing.


static func run_tests() -> void:
	# Tests for a list of AutoArrows

	# Default data
	var output_data: Variant = AutoArrows.new().to_raw_data()
	assert(ParseUtils.is_empty_array(output_data))

	# No data
	output_data = AutoArrows.from_raw_data([]).to_raw_data()
	assert(ParseUtils.is_empty_array(output_data))

	# Invalid data
	output_data = AutoArrows.from_raw_data("bruh").to_raw_data()
	assert(output_data is String and output_data == "bruh")
	output_data = AutoArrows.from_raw_data(null).to_raw_data()
	assert(output_data == null)

	# One invalid arrow
	output_data = AutoArrows.from_raw_data(["amogus"]).to_raw_data()
	assert(output_data is Array and output_data == ["amogus"])
	output_data = AutoArrows.from_raw_data([null]).to_raw_data()
	assert(output_data is Array and output_data == [null])

	# Many invalid arrows
	output_data = AutoArrows.from_raw_data(
			[null, "bruh", ["amogus"], null, 6.7]
	).to_raw_data()
	assert(
			output_data is Array
			and output_data == [null, "bruh", ["amogus"], null, 6.7]
	)

	# Valid and invalid arrows
	var input_data: Variant = [
		{},
		{ "six": "sevennn", "sus": "amogus" },
		{ AutoArrow._DEST_PROVINCE_ID_KEY: 67 },
		{
			AutoArrow._DEST_PROVINCE_ID_KEY: 6767,
			AutoArrow._SOURCE_PROVINCE_ID_KEY: 3
		},
		["hi"],
		{
			AutoArrow._DEST_PROVINCE_ID_KEY: 1,
			AutoArrow._SOURCE_PROVINCE_ID_KEY: 420
		},
		{},
		{
			AutoArrow._DEST_PROVINCE_ID_KEY: 6,
			AutoArrow._SOURCE_PROVINCE_ID_KEY: 6
		}
	]
	output_data = AutoArrows.from_raw_data(input_data).to_raw_data()
	assert(output_data is Array and output_data == input_data)

	# One valid arrow
	input_data = [{
		AutoArrow._SOURCE_PROVINCE_ID_KEY: 34,
		AutoArrow._DEST_PROVINCE_ID_KEY: 2
	}]
	output_data = AutoArrows.from_raw_data(input_data).to_raw_data()
	assert(output_data is Array and output_data == input_data)

	# Arrow with the same id for both source and destination (still valid)
	input_data = [{
		AutoArrow._SOURCE_PROVINCE_ID_KEY: 3,
		AutoArrow._DEST_PROVINCE_ID_KEY: 3
	}]
	output_data = AutoArrows.from_raw_data(input_data).to_raw_data()
	assert(output_data is Array and output_data == input_data)

	# Arrow with id 0 (still valid)
	input_data = [{
		AutoArrow._SOURCE_PROVINCE_ID_KEY: 0,
		AutoArrow._DEST_PROVINCE_ID_KEY: 36
	}]
	output_data = AutoArrows.from_raw_data(input_data).to_raw_data()
	assert(output_data is Array and output_data == input_data)

	# Many valid arrows
	input_data = [
		{
			AutoArrow._SOURCE_PROVINCE_ID_KEY: 6,
			AutoArrow._DEST_PROVINCE_ID_KEY: 7
		},
		{
			AutoArrow._SOURCE_PROVINCE_ID_KEY: 60,
			AutoArrow._DEST_PROVINCE_ID_KEY: 17
		},
		{
			AutoArrow._SOURCE_PROVINCE_ID_KEY: 4,
			AutoArrow._DEST_PROVINCE_ID_KEY: 20
		}
	]
	output_data = AutoArrows.from_raw_data(input_data).to_raw_data()
	assert(output_data is Array and output_data == input_data)

	# Extra data in an arrow's dictionary
	input_data = [
		{
			AutoArrow._SOURCE_PROVINCE_ID_KEY: 7,
			AutoArrow._DEST_PROVINCE_ID_KEY: 6,
			"funny": 67
		},
		{
			"six sevennn": "YAHHHH",
			"im so funny": [67, 6.7, "67"]
		},
		{
			AutoArrow._SOURCE_PROVINCE_ID_KEY: 13,
			AutoArrow._DEST_PROVINCE_ID_KEY: 37,
			"auto_arrows": {"amogus": 67}
		}
	]
	output_data = AutoArrows.from_raw_data(input_data).to_raw_data()
	assert(output_data is Array and output_data == input_data)

	# Discard negative province ids
	input_data = [
		{
			AutoArrow._SOURCE_PROVINCE_ID_KEY: -5,
			AutoArrow._DEST_PROVINCE_ID_KEY: 67
		},
		{
			AutoArrow._SOURCE_PROVINCE_ID_KEY: 4,
			AutoArrow._DEST_PROVINCE_ID_KEY: -222
		},
		{
			AutoArrow._SOURCE_PROVINCE_ID_KEY: -7,
			AutoArrow._DEST_PROVINCE_ID_KEY: -8
		},
		{
			AutoArrow._SOURCE_PROVINCE_ID_KEY: -1,
			AutoArrow._DEST_PROVINCE_ID_KEY: -1
		}
	]
	output_data = AutoArrows.from_raw_data(input_data).to_raw_data()
	assert(output_data is Array and output_data == [
		{ AutoArrow._DEST_PROVINCE_ID_KEY: 67 },
		{ AutoArrow._SOURCE_PROVINCE_ID_KEY: 4 },
		{},
		{}
	])

	# Province ids are not a number
	input_data = [
		{
			AutoArrow._SOURCE_PROVINCE_ID_KEY: "💀💀💀",
			AutoArrow._DEST_PROVINCE_ID_KEY: [67]
		}
	]
	output_data = AutoArrows.from_raw_data(input_data).to_raw_data()
	assert(output_data is Array and output_data == [{}])

	# Tests for one AutoArrow
	output_data = AutoArrow.new(-1, -1).to_raw_data()
	assert(ParseUtils.is_empty_dict(output_data))
	output_data = AutoArrow.new(-6, -1).to_raw_data()
	assert(ParseUtils.is_empty_dict(output_data))
	output_data = AutoArrow.new(-67, -420).to_raw_data()
	assert(ParseUtils.is_empty_dict(output_data))
	output_data = AutoArrow.new(67, -4).to_raw_data()
	assert(output_data is Dictionary and output_data == {
		AutoArrow._SOURCE_PROVINCE_ID_KEY: 67
	})
	output_data = AutoArrow.new(-8, 2).to_raw_data()
	assert(output_data is Dictionary and output_data == {
		AutoArrow._DEST_PROVINCE_ID_KEY: 2
	})
	output_data = AutoArrow.new(670, 6677).to_raw_data()
	assert(output_data is Dictionary and output_data == {
		AutoArrow._SOURCE_PROVINCE_ID_KEY: 670,
		AutoArrow._DEST_PROVINCE_ID_KEY: 6677
	})
