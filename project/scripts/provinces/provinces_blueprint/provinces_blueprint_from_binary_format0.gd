class_name ProvincesBlueprintFromBinaryFormat0
extends ProvincesBlueprintFromData
## A provinces blueprint built from a given [BitArrayCursor].[br]
## Specifically builds it from format 0.


func _init(cursor: BitArrayCursor) -> void:
	_version = 0
	
	# Get the vertex data (there must be at least 3 vertices)
	var vertex_data := Vector2iArrayFromBits.new()
	if vertex_data.read(cursor) or vertex_data.values_x().size() < 3:
		_error = ParseError.CORRUPTED_DATA
		return
	var vertex_x: PackedInt32Array = vertex_data.values_x()
	var vertex_y: PackedInt32Array = vertex_data.values_y()
	var number_of_vertices: int = vertex_x.size()
	
	# Get the number of provinces to be found (must not be 0)
	var uint31_from_bits := UInt31FromBits.new()
	if uint31_from_bits.read(cursor) or uint31_from_bits.value() == 0:
		_error = ParseError.CORRUPTED_DATA
		return
	var number_of_provinces: int = uint31_from_bits.value()
	
	# Get the bit size for the number of vertices of each province
	var bit_size_from_bits := BitSizeFromBits.new()
	if bit_size_from_bits.read(cursor):
		_error = ParseError.CORRUPTED_DATA
		return
	var bit_size_vertices_per_province: int = bit_size_from_bits.value()
	
	# Get the province data
	var bit_size_vertex_id: int = BitSize.of_number(number_of_vertices - 1)
	var province_ids: PackedInt32Array = []
	var province_shapes: Array[ProvinceShape] = []
	for j in number_of_provinces:
		# Get the number of vertices for this province
		if cursor.bits_remaining() < bit_size_vertices_per_province:
			_error = ParseError.CORRUPTED_DATA
			return
		var number_of_vertices_in_province: int = (
				cursor.next_bits(bit_size_vertices_per_province)
		)
		# Each shape must have at least 3 vertices
		if number_of_vertices_in_province < 3:
			_error = ParseError.CORRUPTED_DATA
			return
		
		var province_vertex_x: PackedInt32Array = []
		var province_vertex_y: PackedInt32Array = []
		
		for i in number_of_vertices_in_province:
			# Get the vertex id
			if cursor.bits_remaining() < bit_size_vertex_id:
				_error = ParseError.CORRUPTED_DATA
				return
			var vertex_id: int = cursor.next_bits(bit_size_vertex_id)
			
			# Return an error if the vertex id is invalid
			if vertex_id >= number_of_vertices:
				_error = ParseError.CORRUPTED_DATA
				return
			
			province_vertex_x.append(vertex_x[vertex_id])
			province_vertex_y.append(vertex_y[vertex_id])
		
		province_ids.append(province_ids.size())
		province_shapes.append(ProvinceShapeFromVertices.new(
				province_vertex_x,
				province_vertex_y
		))
	
	# We successfully obtained all the data we need!
	_province_ids = province_ids
	_province_shapes = province_shapes


## TODO verify the contents of province shapes when it works
static func _unit_test() -> void:
	# Check when you can't get the vertex data
	var cursor_1 := BitArrayCursor.new(BitArray.new([0b01000000]))
	var result_1 := ProvincesBlueprintFromBinaryFormat0.new(cursor_1)
	assert(
			result_1._version == 0
			and result_1._error == ParseError.CORRUPTED_DATA
	)
	
	# Check when the number of vertices is less than 3
	var cursor_2 := BitArrayCursor.new(BitArray.new([
		0b00001100, 0b00000000, 0b00000000, 0b00000000, 0b00000000,
	]))
	var result_2 := ProvincesBlueprintFromBinaryFormat0.new(cursor_2)
	assert(
			result_2._version == 0
			and result_2._error == ParseError.CORRUPTED_DATA
	)
	
	# Check when you can't get the number of provinces
	var cursor_3 := BitArrayCursor.new(BitArray.new([
		0b00010100, 0b00010001, 0b00111000, 0b10011101, 0b10110000,
	]))
	var result_3 := ProvincesBlueprintFromBinaryFormat0.new(cursor_3)
	assert(
			result_3._version == 0
			and result_3._error == ParseError.CORRUPTED_DATA
	)
	
	# Check when the number of provinces is 0
	var cursor_4 := BitArrayCursor.new(BitArray.new([
		0b00010100, 0b00010001, 0b00111000, 0b10011101, 0b10110000,
		0b00000000, 0b00000000, 0b00000000,
	]))
	var result_4 := ProvincesBlueprintFromBinaryFormat0.new(cursor_4)
	assert(
			result_4._version == 0
			and result_4._error == ParseError.CORRUPTED_DATA
	)
	
	# Check when you can't get the bit size of verts per province
	var cursor_5 := BitArrayCursor.new(BitArray.new([
		0b00010100, 0b00010001, 0b00111000, 0b10011101, 0b10110000,
		0b01100000,
	]))
	var result_5 := ProvincesBlueprintFromBinaryFormat0.new(cursor_5)
	assert(
			result_5._version == 0
			and result_5._error == ParseError.CORRUPTED_DATA
	)
	
	# Check when you run out of bits for the number of vertices
	var cursor_6 := BitArrayCursor.new(BitArray.new([
		0b00010101, 0b00010001, 0b00111000, 0b10011101, 0b10110100,
		0b10000001, 0b10000011,
	]))
	var result_6 := ProvincesBlueprintFromBinaryFormat0.new(cursor_6)
	assert(
			result_6._version == 0
			and result_6._error == ParseError.CORRUPTED_DATA
	)
	
	# Check when a province shape has less than 3 vertices
	var cursor_7 := BitArrayCursor.new(BitArray.new([
		0b00010101, 0b00010001, 0b00111000, 0b10011101, 0b10110100,
		0b10000001, 0b10000010, 0b10010101, 0b10000000,
	]))
	var result_7 := ProvincesBlueprintFromBinaryFormat0.new(cursor_7)
	assert(
			result_7._version == 0
			and result_7._error == ParseError.CORRUPTED_DATA
	)
	
	# Check when you run out of bits for the vertex indices
	var cursor_8 := BitArrayCursor.new(BitArray.new([
		0b00010101, 0b00010001, 0b00111000, 0b10011101, 0b10110100,
		0b10000001, 0b10000011, 0b10000110,
	]))
	var result_8 := ProvincesBlueprintFromBinaryFormat0.new(cursor_8)
	assert(
			result_8._version == 0
			and result_8._error == ParseError.CORRUPTED_DATA
	)
	
	# Check when a vertex is invalid
	var cursor_9 := BitArrayCursor.new(BitArray.new([
		0b00010101, 0b00010001, 0b00111000, 0b10011101, 0b10110100,
		0b10000001, 0b10000011, 0b10000111, 0b10000000, 0b00000000,
	]))
	var result_9 := ProvincesBlueprintFromBinaryFormat0.new(cursor_9)
	assert(
			result_9._version == 0
			and result_9._error == ParseError.CORRUPTED_DATA
	)
	
	# Check when everything works
	var cursor_10 := BitArrayCursor.new(BitArray.new([
		0b00010100, 0b00010001, 0b00111000, 0b10011101, 0b10110000,
		0b01100000, 0b11100011, 0b01101101, 0b10000000,
	]))
	var result_10 := ProvincesBlueprintFromBinaryFormat0.new(cursor_10)
	assert(
			result_10._version == 0
			and result_10._error == ParseError.OK
			and result_10._province_ids == PackedInt32Array([0, 1])
			and result_10._province_shapes.size() == 2
			and (result_10._province_shapes[0] as ProvinceShapeFromVertices)
			._vertices_x == PackedInt32Array([1, 6, 1])
			and (result_10._province_shapes[0] as ProvinceShapeFromVertices)
			._vertices_y == PackedInt32Array([1, 1, 6])
			and (result_10._province_shapes[1] as ProvinceShapeFromVertices)
			._vertices_x == PackedInt32Array([6, 1, 6])
			and (result_10._province_shapes[1] as ProvinceShapeFromVertices)
			._vertices_y == PackedInt32Array([1, 6, 6])
	)
