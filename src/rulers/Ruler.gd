extends Button

var major_subdivision :int = 2
var minor_subdivision :int = 4

var first: Vector2
var last: Vector2

const R_WIDTH :int = 16


func _ready():
	# TODO listen notifications.
	pass


func _gui_input(_event: InputEvent):
	# TODO move guides
	pass


# Code taken and modified from Godot's source code
func _draw():
#	var font = ThemeDB.fallback_font
	var transform = Transform2D()
	var ruler_transform = Transform2D()
	var major_subdivide = Transform2D()
	var minor_subdivide = Transform2D()
	var zoom = g.camera.zoom.x
	var canvas_size :Vector2 = g.viewport.size
	
	transform.x = Vector2(zoom, zoom)

	# This tracks the "true" top left corner of the drawing:
	transform.origin = canvas_size / 2

	var proj_size :Vector2 = g.current_project.size

	# Calculating the rotated corners of the image, use min to find the farthest left
	var top_left :Vector2 = Vector2.ZERO  # Top left
	var top_right :Vector2 = Vector2(proj_size.x, 0) # Top right
	var bottom_left :Vector2 = Vector2(0, proj_size.y) # Bottom left
	var bottom_right :Vector2 = Vector2(proj_size.x, proj_size.y) # Bottom right
	transform.origin.x += minf(minf(top_left.x, top_right.x), 
							   minf(bottom_left.x, bottom_right.x)) * zoom

	var basic_rule :float = 100.0
	var i :int = 0
	while basic_rule * zoom > 100:
		basic_rule /= 5.0 if i % 2 else 2.0
		i += 1
	i = 0
	while basic_rule * zoom < 100:
		basic_rule *= 2.0 if i % 2 else 5.0
		i += 1

	ruler_transform = ruler_transform.scaled(Vector2(basic_rule, basic_rule))

	major_subdivide = major_subdivide.scaled(
		Vector2(1.0 / major_subdivision, 1.0 / major_subdivision)
	)
	minor_subdivide = minor_subdivide.scaled(
		Vector2(1.0 / minor_subdivision, 1.0 / minor_subdivision)
	)

	first = (
		(transform * ruler_transform * major_subdivide * minor_subdivide)
		.affine_inverse() * Vector2.ZERO
	)
	last = (
		(transform * ruler_transform * major_subdivide * minor_subdivide)
		.affine_inverse() * canvas_size
	)

	for j in range(ceili(first.x), ceili(last.x)):
		var pos: Vector2 = (
			(transform * ruler_transform * major_subdivide * minor_subdivide)
			 * (Vector2(j, 0))
		)
		if j % (major_subdivision * minor_subdivision) == 0:
			draw_line(
				Vector2(pos.x + R_WIDTH, 0),
				Vector2(pos.x + R_WIDTH, R_WIDTH),
				Color.WHITE
			)
			
			# draw numbers
			
#			var val :int= (
#				(ruler_transform * major_subdivide * minor_subdivide)
#				 * Vector2(j, 0)
#			).x

#			draw_string(
#				font,
#				Vector2(pos.x + R_WIDTH + 2, 6),
#				str(snappedf(val, 0.1)),
#				HORIZONTAL_ALIGNMENT_LEFT, 
#				-1, 9
#			)
		else:
			if j % minor_subdivision == 0:
				draw_line(
					Vector2(pos.x + R_WIDTH, R_WIDTH * 0.33),
					Vector2(pos.x + R_WIDTH, R_WIDTH),
					Color.WHITE
				)
			else:
				draw_line(
					Vector2(pos.x + R_WIDTH, R_WIDTH * 0.66),
					Vector2(pos.x + R_WIDTH, R_WIDTH),
					Color.WHITE
				)


func _on_mouse_entered():
	var mouse_pos := get_local_mouse_position()
	if mouse_pos.x < R_WIDTH:  # For double guides
		mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	else:
		mouse_default_cursor_shape = Control.CURSOR_VSPLIT
