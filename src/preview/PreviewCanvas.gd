class_name PreviewCanvas extends Node2D

var project: Project


func attach_project(proj):
	if project != null and project.updated.is_connected(queue_redraw):
		project.updated.disconnect(queue_redraw)
	project = proj
	project.updated.connect(queue_redraw)


func _draw():
	if not project or not project.current_cel:
		return

	# Draw current frame layers
	for i in project.layers.size():
		var cels = project.current_frame.cels 
		if cels[i] is GroupCel:
			continue
		var modulate_color := Color(1, 1, 1, project.layers[i].opacity)
		if project.layers[i].is_visible_in_hierarchy():
			var tex = cels[i].image_texture
			draw_texture(tex, Vector2.ZERO, modulate_color)
