class_name ProvincePathfinding
## Generates the shortest paths from any province to some given destinations.

## An empty array means there is no valid path.
## There may be more than one shortest path.
## Every province is guaranteed to be in this dictionary, and null too.
var paths: Dictionary[Province, LinkBranches] = { null: LinkBranches.new() }

var _provinces: Provinces


func _init(provinces: Provinces) -> void:
	_provinces = provinces


## Generates the shortest paths to any of given provinces.
## Generates a new dictionary each time it's used.
func generate(destinations: Array[Province]) -> void:
	paths = { null: LinkBranches.new() }

	var province_list: Array[Province] = _provinces.list()
	# Make sure all provinces are in the dictionary,
	# even those that don't have a valid path.
	for province in province_list:
		paths[province] = LinkBranches.new()

	var is_not_stuck: bool = true

	# Keep track of which provinces have already been pathed.
	# We use dictionaries for performance.
	var already_pathed_provinces: Dictionary[Province, int] = {}
	var found_provinces: Dictionary[Province, int] = {}

	var link_branches: Array[LinkBranch] = []
	for destination in destinations:
		var link_branch := LinkBranch.new()
		link_branch.link_chain = [destination]
		link_branches.append(link_branch)
		already_pathed_provinces[destination] = 1

	while is_not_stuck:
		# If we don't find a new province, it means we're stuck and no more
		# progress can be made, in which case we'll need to exit the loop.
		is_not_stuck = false

		already_pathed_provinces.merge(found_provinces)
		found_provinces = {}

		# Extend the branches to look for provinces further away.
		var new_link_branches: Array[LinkBranch] = []
		for link_branch in link_branches:
			for next_link_id in (
					link_branch.furthest_link().linked_province_ids()
			):
				var next_linked_province: Province = (
						_provinces.province_from_id(next_link_id)
				)
				if next_linked_province == null:
					push_error("Linked province is null.")
					continue

				if already_pathed_provinces.has(next_linked_province):
					continue

				paths[next_linked_province].list.append(link_branch)

				if found_provinces.has(next_linked_province):
					continue

				new_link_branches.append(
						link_branch.extended_with(next_linked_province)
				)
				found_provinces[next_linked_province] = 1
				is_not_stuck = true

		# Only keep branches that are still finding new provinces.
		link_branches = new_link_branches


## Just an array of [LinkBranch].
class LinkBranches:
	var list: Array[LinkBranch] = []
