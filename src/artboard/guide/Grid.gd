class_name Grid extends Node2D

enum {
	NONE,
	ALL,
	CARTESIAN,
	ISOMETRIC,
}
var state := NONE :
	set(val):
		state = val
		if state == NONE:
			hide()
		else:
			show()
		queue_redraw()

var isometric_grid_size := Vector2i(96, 48)
var grid_size := Vector2i(48, 48)
var grid_color := Color.DEEP_SKY_BLUE:
	set(val):
		grid_color = val
		isometric_grid_color = Color(val)
		isometric_grid_color.a *= 0.66
var isometric_grid_color := Color(0, 0.74902, 0.66)
var pixel_grid_color := Color.LIGHT_BLUE

var show_pixel_grid_at_zoom := 16

var zoom_at := 1.0 :
	set(val):
		zoom_at = val
		queue_redraw()

var show_pixel_grid := false
var show_cartesian_grid := false
var show_isometric_grid := false


var canvas_size := Vector2i.ZERO :
	set(val):
		canvas_size = val
		queue_redraw()
		
var boundary :Rect2 :
	get: return Rect2(Vector2.ZERO, canvas_size)


func _draw():
	if not boundary.has_area():
		return

	if show_cartesian_grid:
		draw_cartesian_grid()
	
	if show_isometric_grid:
		draw_isometric_grid()
	
	if show_pixel_grid and zoom_at >= show_pixel_grid_at_zoom:
		draw_pixel_grid()


func draw_cartesian_grid():
	var grid_multiline_points := PackedVector2Array()

	var x :float = (
		boundary.position.x + fposmod(boundary.position.x, grid_size.x))
	while x <= boundary.end.x:
		grid_multiline_points.push_back(Vector2(x, boundary.position.y))
		grid_multiline_points.push_back(Vector2(x, boundary.end.y))
		x += grid_size.x

	var y :float = (
		boundary.position.y + fposmod(boundary.position.y, grid_size.y))
	while y <= boundary.end.y:
		grid_multiline_points.push_back(Vector2(boundary.position.x, y))
		grid_multiline_points.push_back(Vector2(boundary.end.x, y))
		y += grid_size.y

	if not grid_multiline_points.is_empty():
		draw_multiline(grid_multiline_points, grid_color)


func draw_isometric_grid():
	var grid_multiline_points := PackedVector2Array()

	var cell_size := isometric_grid_size
	var max_cell_count := boundary.size / Vector2(cell_size)
	var origin_offset := Vector2(boundary.position).posmodv(cell_size)

	# lines ↗↗↗ (from bottom-left to top-right)
	var per_cell_offset := cell_size * Vector2i(1, -1)

	#  lines ↗↗↗ starting from the rect's left side (top to bottom):
	var y :float = fposmod(
		origin_offset.y + cell_size.y * (0.5 + origin_offset.x / cell_size.x),
		cell_size.y)
		
	while y < boundary.size.y:
		var start :Vector2 = boundary.position + Vector2(0, y)
		var cells_to_rect_bounds = minf(max_cell_count.x, y / cell_size.y)
		var end :Vector2 = start + cells_to_rect_bounds * per_cell_offset
		grid_multiline_points.push_back(start)
		grid_multiline_points.push_back(end)
		y += cell_size.y

	#  lines ↗↗↗ starting from the boundary's bottom side (left to right):
	var x :float = (y - boundary.size.y) / cell_size.y * cell_size.x
	while x < boundary.size.x:
		var start :Vector2 = boundary.position + Vector2(x, boundary.size.y)
		var cells_to_rect_bounds = minf(max_cell_count.y, 
										max_cell_count.x - x / cell_size.x)
		var end :Vector2 = start + cells_to_rect_bounds * per_cell_offset
		grid_multiline_points.push_back(start)
		grid_multiline_points.push_back(end)
		x += cell_size.x

	# lines ↘↘↘ (from top-left to bottom-right)
	per_cell_offset = cell_size

	#  lines ↘↘↘ starting from the boundary's left side (top to bottom):
	y = fposmod(
		origin_offset.y - cell_size.y * (0.5 + origin_offset.x / cell_size.x),
		cell_size.y)
		
	while y < boundary.size.y:
		var start :Vector2 = boundary.position + Vector2(0, y)
		var cells_to_rect_bounds = minf(
			max_cell_count.x, max_cell_count.y - y / cell_size.y)
		var end :Vector2 = start + cells_to_rect_bounds * per_cell_offset
		grid_multiline_points.push_back(start)
		grid_multiline_points.push_back(end)
		y += cell_size.y

	#  lines ↘↘↘ starting from the boundary's top side (left to right):
	var _x = origin_offset.x - cell_size.x * \
			 (0.5 + origin_offset.y / cell_size.y)
	x = fposmod(_x, cell_size.x)
	while x < boundary.size.x:
		var start :Vector2 = Vector2(boundary.position) + Vector2(x, 0)
		var cells_to_rect_bounds = minf(max_cell_count.y,
										max_cell_count.x - x / cell_size.x)
		var end :Vector2 = start + cells_to_rect_bounds * per_cell_offset
		grid_multiline_points.push_back(start)
		grid_multiline_points.push_back(end)
		x += cell_size.x

	if not grid_multiline_points.is_empty():
		draw_multiline(grid_multiline_points, isometric_grid_color)


func draw_pixel_grid():
	var grid_multiline_points = PackedVector2Array()
	for x in range(ceili(boundary.position.x), floori(boundary.end.x) + 1):
		grid_multiline_points.push_back(Vector2(x, boundary.position.y))
		grid_multiline_points.push_back(Vector2(x, boundary.end.y))

	for y in range(ceili(boundary.position.y), floori(boundary.end.y) + 1):
		grid_multiline_points.push_back(Vector2(boundary.position.x, y))
		grid_multiline_points.push_back(Vector2(boundary.end.x, y))

	if not grid_multiline_points.is_empty():
		draw_multiline(grid_multiline_points, pixel_grid_color)
