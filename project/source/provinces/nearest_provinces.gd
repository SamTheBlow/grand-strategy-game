class_name NearestProvinces
## Class responsible for finding the nearest provinces to given [Province]
## that pass a given filter. For example, you can search for the
## nearest provinces that a certain country doesn't control.

## The number of nearest provinces.
## It's the same as both first_links.size() and furthest_links.size().
var size: int = 0
## The first step to reach a nearest province from given province.
var first_links: Array[Province] = []
## The nearest provinces.
var furthest_links: Array[Province] = []


## The filter must take one input of type Province and must return a boolean.
func calculate(
		province_id: int, provinces: Provinces, province_filter: Callable
) -> void:
	var link_branches: Array[LinkBranch] = (
			_generated_link_branches(province_id, provinces, province_filter)
	)
	size = link_branches.size()
	first_links = []
	furthest_links = []
	for link_branch in link_branches:
		first_links.append(link_branch.first_link())
		furthest_links.append(link_branch.furthest_link())


func _generated_link_branches(
		province_id: int, provinces: Provinces, filter: Callable,
) -> Array[LinkBranch]:
	var is_not_stuck: bool = true

	# Keep track of which provinces have already been searched.
	# We use dictionaries for performance.
	var already_searched_provinces: Dictionary[Province, int] = {}

	var link_branches: Array[LinkBranch] = []
	for linked_province in provinces.links_of(province_id):
		var link_branch := LinkBranch.new()
		link_branch.link_chain = [linked_province]
		link_branches.append(link_branch)
		already_searched_provinces[linked_province] = 1

	while is_not_stuck:
		# Get a list of all the branches that pass the filter.
		var valid_branches: Array[LinkBranch] = []
		for link_branch in link_branches:
			if filter.call(link_branch.furthest_link()):
				valid_branches.append(link_branch)

		# Found one or more valid branches?
		# Then we're done, these are the nearest provinces.
		if valid_branches.size() > 0:
			return valid_branches

		# If we don't find a new province, it means we're stuck and no more
		# progress can be made, in which case we'll need to exit the loop.
		is_not_stuck = false

		# Extend the branches to look for provinces further away.
		var new_link_branches: Array[LinkBranch] = []
		for link_branch in link_branches:
			for next_linked_province in (
					provinces.links_of(link_branch.furthest_link().id)
			):
				if already_searched_provinces.has(next_linked_province):
					continue

				new_link_branches.append(
						link_branch.extended_with(next_linked_province)
				)
				already_searched_provinces[next_linked_province] = 1
				is_not_stuck = true

		# Only keep branches that are still finding new provinces.
		link_branches = new_link_branches

	return []


## Intended for debugging purposes
func _print_branches(branches: Array[LinkBranch]) -> void:
	print("--- Branch tree ---")
	for branch in branches:
		print("Branch:")
		for province in branch.link_chain:
			print(
					"	Id: ", province.id,
					"; Country: ", province.owner_country.name_or_default()
			)
	print("End of branch tree.")
