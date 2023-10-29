class_name Frame extends RefCounted
# A class for frame properties.
# A frame is a collection of cels, for each layer.

var cels: Array[BaseCel]
var duration := 1.0


func append_cel(cel :BaseCel):
	cels.append(cel)
	

func erase_cel(cel :BaseCel):
	if cels.has(cel):
		cels.erase(cel)


func get_images() -> Array[Image]:
	var images :Array[Image] = []
	for cel in cels:
		if cel is PixelCel and cel.is_visible:
			var img :Image = cel.get_image()
			# cel img will never be true of is_empty().
			if not img.is_invisible() or images.size() < 1:
				images.append(cel.get_image())
	return images
