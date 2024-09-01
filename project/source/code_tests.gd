extends Node
## Helper class for running different tests on code.
## 
## To use, simply edit this code to add in the desired tests,
## then toggle the flags to make the tests run.
## The tests will run automatically every time the game is run.


const RUN_IN_DEBUG_BUILDS_ONLY: bool = true
const RUN_PERFORMANCE_TESTS: bool = false
const RUN_UNIT_TESTS: bool = true


func _ready() -> void:
	if RUN_IN_DEBUG_BUILDS_ONLY and not OS.is_debug_build():
		return
	
	if RUN_PERFORMANCE_TESTS:
		_run_performance_test()
	if RUN_UNIT_TESTS:
		_run_unit_test()


func _run_performance_test() -> void:
	print("[PERFORMANCE TEST] Starting performance test")
	
	var number_of_tests: int = 1000000
	
	var time_start: int = Time.get_ticks_usec()
	
	for i in number_of_tests:
		# Method 1 goes here
		pass
	
	var time_end: int = Time.get_ticks_usec()
	
	var time_elapsed: int = time_end - time_start
	print("[PERFORMANCE TEST] Time taken for method 1: " + str(time_elapsed))
	
	time_start = Time.get_ticks_usec()
	
	for i in number_of_tests:
		# Method 2 goes here
		pass
	
	time_end = Time.get_ticks_usec()
	
	time_elapsed = time_end - time_start
	print("[PERFORMANCE TEST] Time taken for method 2: " + str(time_elapsed))
	
	print("[PERFORMANCE TEST] End of performance test")


func _run_unit_test() -> void:
	print("[UNIT TEST] Starting unit tests...")
	
	# Run unit tests here
	BitArray._unit_test()
	BitArrayCursor._unit_test()
	BitSize._unit_test()
	BitSizeFromBits._unit_test()
	Int32FromBits._unit_test()
	IntFromData._unit_test()
	UInt31FromBits._unit_test()
	UInt31FromString._unit_test()
	Vector2iArrayFromBits._unit_test()
	
	ProvincesBlueprint._unit_test()
	ProvincesBlueprintFromData._unit_test()
	ProvincesBlueprintFromBinaryFormat0._unit_test()
	ProvincesBlueprintFromBinary._unit_test()
	ProvincesBlueprintFromText._unit_test()
	
	CustomRulesFromFiles._unit_test()
	
	ArmySize._unit_test()
	
	print("[UNIT TEST] All tests passed!")
