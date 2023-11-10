class_name RectShaper extends BaseShaper


func shape_move(pos :Vector2i):
	super.shape_move(pos)
	if is_shaping:
		if points.size() > 1:
			# only keep frist points for rectangle.
			points.resize(1)
		points.append(pos) # append last point for rectangle.
		silhouette.shaping_rectangle(points)
	elif is_dragging:
		silhouette.drag_to(pos, drag_offset)


func apply():
	if points.size() > 0:  # only current shaper has points.
		history.record(silhouette.image)
		silhouette.shaped_rectangle()
		history.commit('shape')
	super.apply()
