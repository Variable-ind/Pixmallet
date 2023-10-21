class_name PreviewCamera extends Camera2D

var canvas_size := Vector2i.ZERO

var zoom_level_min := 10.0
var zoom_level_max := 1.0
var zoom_level := 1.0


func zoom_to(val:float):
	zoom_level = clamp(val, zoom_level_min, zoom_level_max)
	zoom = Vector2.ONE * zoom_level
	offset = canvas_size * 0.5


func zoom_in():
	zoom_level = max(zoom_level + 1, zoom_level_max)
	zoom = Vector2.ONE * zoom_level
	offset = canvas_size * 0.5


func zoom_out():
	zoom_level = max(zoom_level - 1, zoom_level_min)
	zoom = Vector2.ONE * zoom_level
	offset = canvas_size * 0.5
	
