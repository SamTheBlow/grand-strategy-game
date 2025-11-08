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
	ProjectVersion._unit_test()
	AutoArrowUnitTest.run_tests()

	print("[UNIT TEST] All tests passed!")
