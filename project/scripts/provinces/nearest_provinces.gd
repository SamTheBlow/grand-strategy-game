class_name NearestProvinces
## Class responsible for finding a [Province]'s nearest provinces.


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
			_find_nearest_provinces_recursive(province, province_filter)
	)
	size = link_branches.size()
	first_links = []
	furthest_links = []
	for link_branch in link_branches:
		first_links.append(link_branch.first_link())
		furthest_links.append(link_branch.furthest_link())


func _find_nearest_provinces_recursive(
		province: Province,
		filter: Callable,
		link_branches: Array[LinkBranch] = _new_link_branches(province),
		depth: int = 0,
) -> Array[LinkBranch]:
	# Prevent infinite loop if it's impossible to find a target to capture
	# FIXME this will stop searching too early on very large maps
	if depth >= 100:
		return []
	
	# Get a list of all the branches that pass the filter
	var valid_branches: Array[LinkBranch] = []
	for link_branch in link_branches:
		if filter.call(link_branch.furthest_link()):
			valid_branches.append(link_branch)
	
	if valid_branches.size() > 0:
		return valid_branches
	
	var new_link_branches: Array[LinkBranch] = []
	
	# Make a list of all the provinces we've already searched
	var already_searched_provinces: Array[Province] = [province]
	for link_branch in link_branches:
		for link in link_branch.link_chain:
			if already_searched_provinces.find(link) == -1:
				already_searched_provinces.append(link)
	
	# Get the linked provinces that have not been searched yet
	for link_branch in link_branches:
		var next_links: Array[Province] = link_branch.furthest_link().links
		for next_link in next_links:
			if already_searched_provinces.find(next_link) == -1:
				new_link_branches.append(link_branch.extended_with(next_link))
				already_searched_provinces.append(next_link)
	
	# Look for provinces further away
	return _find_nearest_provinces_recursive(
			province, filter, new_link_branches, depth + 1
	)


func _new_link_branches(province: Province) -> Array[LinkBranch]:
	var link_branches: Array[LinkBranch] = []
	for link in province.links:
		var link_branch := LinkBranch.new()
		link_branch.link_chain = [link]
		link_branches.append(link_branch)
	return link_branches


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
