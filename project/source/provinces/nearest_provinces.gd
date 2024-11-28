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
		province: Province, province_filter: Callable
) -> void:
	var link_branches: Array[LinkBranch] = (
			_generated_link_branches(province, province_filter)
	)
	size = link_branches.size()
	first_links = []
	furthest_links = []
	for link_branch in link_branches:
		first_links.append(link_branch.first_link())
		furthest_links.append(link_branch.furthest_link())


func _generated_link_branches(
		province: Province, filter: Callable,
) -> Array[LinkBranch]:
	var is_not_stuck: bool = true

	# Keep track of which provinces have already been searched.
	var already_searched_provinces: Array[Province] = [province]

	var link_branches: Array[LinkBranch] = []
	for link in province.links:
		var link_branch := LinkBranch.new()
		link_branch.link_chain = [link]
		link_branches.append(link_branch)
		already_searched_provinces.append(link)

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

		# If we haven't found a new province,
		# it means we're stuck and no more progress can be made,
		# in which case we'll need to exit the loop.
		is_not_stuck = false

		# Extend the branches to look for provinces further away.
		var new_link_branches: Array[LinkBranch] = []
		for link_branch in link_branches:
			var next_links: Array[Province] = link_branch.furthest_link().links
			for next_link in next_links:
				if not already_searched_provinces.has(next_link):
					new_link_branches.append(
							link_branch.extended_with(next_link)
					)
					already_searched_provinces.append(next_link)
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
					"; Country: ", province.owner_country.country_name
			)
	print("End of branch tree.")


## Gives information on how to get from one province to another.
## The first province in the array is a link of the original province,
## the second element is a link of the first element, and so on.
class LinkBranch:
	var link_chain: Array[Province] = []

	func first_link() -> Province:
		return link_chain[0]

	func furthest_link() -> Province:
		return link_chain[link_chain.size() - 1]

	## Returns a new link branch with a new link chain.
	## The new link chain is the same as this branch's chain,
	## but with given new link appended at the end.
	func extended_with(new_link: Province) -> LinkBranch:
		var new_branch := LinkBranch.new()
		for link in link_chain:
			new_branch.link_chain.append(link)
		new_branch.link_chain.append(new_link)
		return new_branch
