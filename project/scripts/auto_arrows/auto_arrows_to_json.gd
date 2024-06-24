class_name AutoArrowsToJSON
## Converts an [AutoArrows] object into raw data.
## 
## See also: [AutoArrowsFromJSON], [AutoArrow]


func result(auto_arrows: AutoArrows) -> Array:
	var output: Array = []
	for auto_arrow in auto_arrows._list:
		output.append(AutoArrowToDict.new().result(auto_arrow))
	return output
