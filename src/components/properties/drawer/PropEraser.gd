class_name PropEraser extends VBoxContainer

var operator :Variant
	
@onready var eraser_width := $EraserWidth
@onready var opacity := $Opacity


func subscribe(new_operator:EraseDrawer):
	unsubscribe()
	operator = new_operator
	eraser_width.min_value = operator.STROKE_WIDTH_MIN
	eraser_width.max_value = operator.STROKE_WIDTH_MAX
	eraser_width.value = operator.stroke_width  # max/min defined in operator.
	opacity.value = floor(operator.alpha * 100)
	
	eraser_width.value_changed.connect(_on_eraser_width_changed)
	opacity.value_changed.connect(_on_opacity_changed)


func unsubscribe():
	if eraser_width.value_changed.is_connected(_on_eraser_width_changed):
		eraser_width.value_changed.disconnect(_on_eraser_width_changed)
	if opacity.value_changed.is_connected(_on_opacity_changed):
		opacity.value_changed.disconnect(_on_opacity_changed)
	operator = null


func _on_eraser_width_changed(value):
	operator.stroke_width = value


func _on_opacity_changed(value):
	operator.alpha = value / 100.0
