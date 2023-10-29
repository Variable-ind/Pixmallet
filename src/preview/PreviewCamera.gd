class_name PreviewCamera extends Camera2D

signal zoom_changed(level)

var canvas_size := Vector2i.ZERO:
	set(val):
		canvas_size = val
		set_zoom_fit()
var viewport_size := Vector2i.ZERO:
	set(val):
		viewport_size = val
		set_zoom_fit()

var zoom_ratio_max := 1.0
var zoom_ratio_min := 0.1
var zoom_ratio_step := 0.1

var zoom_level_max := 10
var zoom_level_min := 1
var zoom_level := 1
var zoom_step := 1

var zoom_center_point := Vector2.ZERO
var btn_pressed := false


func zoom_to(level:int):
	zoom_level = level
	var zoom_ratio = zoom_ratio_min + zoom_ratio_step * (zoom_level-1)
	zoom_ratio = minf(zoom_ratio, zoom_ratio_max)
	zoom = Vector2.ONE * zoom_ratio
	zoom_center_point = canvas_size * 0.5
	offset = zoom_center_point
	zoom_changed.emit(zoom_level)


func zoom_in():
	if zoom_level < zoom_level_max:
		zoom_to(zoom_level + 1)


func zoom_out():
	if zoom_level > zoom_level_min:
		zoom_to(zoom_level - 1)


func set_zoom_fit():
	if canvas_size.x < 0 or canvas_size.y < 0 or viewport_size == Vector2i.ZERO:
		return
	var h_ratio = viewport_size.x / float(canvas_size.x)
	var v_ratio = viewport_size.y / float(canvas_size.y)
	zoom_ratio_min = minf(h_ratio, v_ratio)
	zoom_ratio_step = (zoom_ratio_max - zoom_ratio_min) / zoom_level_max
	zoom_level = zoom_level_min
	zoom_to(zoom_level)


func _input(event: InputEvent):
	if event is InputEventPanGesture and OS.get_name() != "Android":
		# Pan Gesture on a laptop touchpad
		offset = offset + event.delta * 7.0 / zoom
		offset = offset.clamp(Vector2i.ZERO, canvas_size)
	
	if event is InputEventMouseButton:
		btn_pressed = event.pressed
		
	if event is InputEventMouseMotion and btn_pressed:
		offset = offset - event.relative / zoom
		offset = offset.clamp(Vector2i.ZERO, canvas_size)
		
