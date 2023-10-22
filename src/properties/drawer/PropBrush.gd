class_name PropBrush extends VBoxContainer

var operator :Variant
	
@onready var stroke_width := $StrokeWidth
@onready var opacity := $Opacity

@onready var opt_spacing := $OptSpacing

@onready var spacing_x := $SpacingX
@onready var spacing_y := $SpacingY


func subscribe(new_operator:BrushDrawer):
	unsubscribe()
	operator = new_operator
	stroke_width.min_value = operator.STROKE_WIDTH_MIN
	stroke_width.max_value = operator.STROKE_WIDTH_MAX
	stroke_width.value = operator.stroke_width  # max/min defined in operator.
	opacity.value = floor(operator.alpha * 100)
	
	opt_spacing.button_pressed = operator.stroke_spacing != Vector2i.ZERO
	spacing_x.value = operator.stroke_spacing.x
	spacing_y.value = operator.stroke_spacing.y
	
	stroke_width.value_changed.connect(_on_stroke_width_changed)
	opacity.value_changed.connect(_on_opacity_changed)
	
	opt_spacing.toggled.connect(_on_spacing_toggled)
	spacing_x.value_changed.connect(_on_spacing_x_changed)
	spacing_y.value_changed.connect(_on_spacing_y_changed)


func unsubscribe():
	if stroke_width.value_changed.is_connected(_on_stroke_width_changed):
		stroke_width.value_changed.disconnect(_on_stroke_width_changed)
	if opacity.value_changed.is_connected(_on_opacity_changed):
		opacity.value_changed.disconnect(_on_opacity_changed)
	if opt_spacing.toggled.is_connected(_on_spacing_toggled):
		opt_spacing.toggled.disconnect(_on_spacing_toggled)
	if spacing_x.value_changed.is_connected(_on_spacing_x_changed):
		spacing_x.value_changed.disconnect(_on_spacing_x_changed)
	if spacing_y.value_changed.is_connected(_on_spacing_y_changed):
		spacing_y.value_changed.disconnect(_on_spacing_y_changed)
	operator = null


func _on_stroke_width_changed(value):
	operator.stroke_width = value


func _on_opacity_changed(value):
	operator.alpha = value / 100.0


func _on_spacing_x_changed(value):
	operator.stroke_spacing.x = value


func _on_spacing_y_changed(value):
	operator.stroke_spacing.y = value


func _on_spacing_toggled(btn_pressed):
	if btn_pressed:
		spacing_x.visible = true
		spacing_y.visible = true
	else:
		spacing_x.visible = false
		spacing_y.visible = false
		spacing_x.value = 0
		spacing_y.value = 0
	
	operator.stroke_spacing.x = spacing_x.value
	operator.stroke_spacing.y = spacing_y.value
