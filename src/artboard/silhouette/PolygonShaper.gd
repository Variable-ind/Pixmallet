class_name PolygonShaper extends BaseShaper


func _init(_silhouette :Silhouette):
	type = POLYGON
	super._init(_silhouette)
	
	
func shape_move(pos :Vector2i):
	super.shape_move(pos)
	if is_shaping:
		if points.size() > 1:
			# only keep frist points for rectangle.
			points.resize(1)
		points.append(pos) # append last point for rectangle.
		silhouette.shaping_polygon(points)
	elif is_dragging:
		silhouette.drag_to(pos, drag_offset)

