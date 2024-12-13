class_name LinkBranch
## Gives information on how to get from one province to another.
## The first province in the array is a link of the original province,
## the second element is a link of the first element, and so on.

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
	new_branch.link_chain = link_chain.duplicate()
	new_branch.link_chain.append(new_link)
	return new_branch
