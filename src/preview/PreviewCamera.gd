class_name PreviewCamera extends Camera2D

var canvas_size := Vector2i.ZERO:
	set(val):
		canvas_size = val
		offset = canvas_size * 0.5

var zoom_level_max := 10.0
var zoom_level_min := 1.0
var zoom_level := 1.0
var zoom_step := 1.0

var zoom_center_point := Vector2.ZERO


func zoom_to(val:float):
	zoom_center_point = canvas_size * 0.5
	zoom_level = clamp(val, zoom_level_min, zoom_level_max)
	zoom = Vector2.ONE * zoom_level


func zoom_in():
	zoom_center_point = canvas_size * 0.5
	zoom_level = min(zoom_level + zoom_step, zoom_level_max)
	zoom = Vector2.ONE * zoom_level


func zoom_out():
	zoom_center_point = canvas_size * 0.5
	zoom_level = max(zoom_level - zoom_step, zoom_level_min)
	zoom = Vector2.ONE * zoom_level


func zoom_100():
	zoom = Vector2.ONE
	zoom_center_point = canvas_size * 0.5
	offset = zoom_center_point
	

func fit_to_frame():
	offset = canvas_size * 0.5
	var h_ratio = viewport_size.x / float(canvas_size.x)
	var v_ratio = viewport_size.y / float(canvas_size.y)
	var ratio = minf(h_ratio, v_ratio)
	ratio = clampf(ratio, 0.1, ratio)
	zoom = Vector2(ratio, ratio)
