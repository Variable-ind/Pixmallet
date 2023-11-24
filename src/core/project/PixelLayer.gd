class_name PixelLayer extends BaseLayer
## A class for standard pixel layer properties.

var is_linked :bool = false
var cel_link_sets :Array[Dictionary] = []
# Each Dictionary represents a cel's "link set"z


# Links a cel to link_set if its a Dictionary, or unlinks if null.
# Content/image_texture are handled separately for undo related reasons
func link_cel(cel: BaseCel, link_set = null):
	# Erase from the cel's current link_set
	if cel.link_set is Dictionary:
		if cel.link_set.has("cels"):
			cel.link_set["cels"].erase(cel)
			if cel.link_set["cels"].is_empty():
				cel_link_sets.erase(cel.link_set)
		else:
			cel_link_sets.erase(cel.link_set)

	# Add to link_set
	cel.link_set = link_set
	if link_set is Dictionary:
		if not link_set.has("cels"):
			link_set["cels"] = []
		link_set["cels"].append(cel)
		if not cel_link_sets.has(link_set):
			if not link_set.has("hue"):
				var hues = PackedFloat32Array()
				for other_link_set in cel_link_sets:
					hues.append(other_link_set["hue"])
				if hues.is_empty():
					link_set["hue"] = Color.GREEN.h
				else:  
					# Calculate the largest gap in hue between existing links.
					hues.sort()
					# Start gap between the highest and lowest hues, 
					# otherwise its hard to include
					var largest_gap_pos = hues[-1]
					var largest_gap_size = 1.0 - (hues[-1] - hues[0])
					for h in hues.size() - 1:
						var gap_size: float = hues[h + 1] - hues[h]
						if gap_size > largest_gap_size:
							largest_gap_pos = hues[h]
							largest_gap_size = gap_size
					link_set["hue"] = wrapf(
						largest_gap_pos + largest_gap_size / 2.0, 0, 1)
			cel_link_sets.append(link_set)


# Overridden Methods:
func set_name_to_default(number: int):
	name = tr("Layer") + " %s" % number


func new_empty_cel(size:Vector2i) -> PixelCel:
	return PixelCel.new(size.x, size.y)


func can_layer_get_drawn() -> bool:
	return is_visible_in_hierarchy() && !is_locked_in_hierarchy()
