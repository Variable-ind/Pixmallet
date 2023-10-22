class_name PreviewCamera extends Camera2D

var canvas_size := Vector2i.ZERO:
	set(val):
		canvas_size = val
		offset = canvas_size * 0.5

var zoom_level_max := 10.0
var zoom_level_min := 1.0
var zoom_level := 1.0
var zoom_step := 1.0


func zoom_to(val:float):
	zoom_level = clamp(val, zoom_level_min, zoom_level_max)
	zoom = Vector2.ONE * zoom_level


func zoom_in():
	zoom_level = min(zoom_level + zoom_step, zoom_level_max)
	zoom = Vector2.ONE * zoom_level


func zoom_out():
	zoom_level = max(zoom_level - zoom_step, zoom_level_min)
	zoom = Vector2.ONE * zoom_level
	
