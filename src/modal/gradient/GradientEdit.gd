class_name GradientEditNode extends Control

signal updated(gradient, cc)

var continuous_change := true
var active_cursor: GradientCursor  
## Showing a color picker popup to change a cursor's color

@onready var x_offset: float = size.x - GradientCursor.WIDTH
@onready var texture_rect := $TextureRect
@onready var texture :GradientTexture2D = texture_rect.texture
@onready var gradient := texture.gradient

@onready var color_picker_popup := $ColorPickerPopup
@onready var color_picker := $ColorPickerPopup/ColorPicker


func _ready():
	create_cursor()


func create_cursor():
	for cur in texture_rect.get_children():
		if cur is GradientCursor:
			texture_rect.remove_child(cur)
			cur.queue_free()
	for i in gradient.get_point_count():
		var p: float = gradient.get_offset(i)
		add_cursor(p * x_offset, gradient.get_color(i))


func _gui_input(ev: InputEvent):
	if ev is InputEventMouseButton:
		if ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			var p := clampf(ev.position.x, 0, x_offset)
			add_cursor(p, get_gradient_color(p))
			continuous_change = false
			update_from_value()


func update_from_value() -> void:
	gradient.offsets = []
	for c in texture_rect.get_children():
		if c is GradientCursor:
			var point: float = c.position.x / x_offset
			gradient.add_point(point, c.color)
	updated.emit(gradient, continuous_change)
	continuous_change = true


func add_cursor(x: float, color: Color):
	var cursor := GradientCursor.new()
	texture_rect.add_child(cursor)
	cursor.position.x = x
	cursor.color = color


func select_color(cursor: GradientCursor, pos: Vector2):
	active_cursor = cursor
	color_picker.color = cursor.color
	if pos.x > global_position.x + (size.x / 2.0):
		pos.x = global_position.x + size.x
	else:
		pos.x = global_position.x - $Popup.size.x
	$Popup.position = pos
	$Popup.popup()


func get_sorted_cursors() -> Array:
	var array: Array[GradientCursor] = []
	for c in texture_rect.get_children():
		if c is GradientCursor:
			array.append(c)
	array.sort_custom(
		func(a: GradientCursor, b: GradientCursor): return a.get_position() < b.get_position()
	)
	return array


func get_gradient_color(x: float) -> Color:
	return gradient.sample(x / x_offset)


func _on_ColorPicker_color_changed(color: Color) -> void:
	active_cursor.set_color(color)


func _on_GradientEdit_resized() -> void:
	if not gradient:
		return
	x_offset = size.x - GradientCursor.WIDTH
	_create_cursors()


func _on_InterpolationOptionButton_item_selected(index: Gradient.InterpolationMode) -> void:
	gradient.interpolation_mode = index


func _on_DivideButton_pressed() -> void:
	divide_dialog.popup_centered()


func _on_DivideConfirmationDialog_confirmed() -> void:
	var add_point_to_end := add_point_end_check_box.button_pressed
	var parts := number_of_parts_spin_box.value
	var colors: PackedColorArray = []
	var end_point := 1 if add_point_to_end else 0
	parts -= end_point

	if not add_point_to_end:
		# Move the final color one part behind, useful for it to be in constant interpolation
		gradient.add_point((parts - 1) / parts, gradient.sample(1))
	for i in parts + end_point:
		colors.append(gradient.sample(i / parts))
	gradient.offsets = []
	for i in parts + end_point:
		gradient.add_point(i / parts, colors[i])
	_create_cursors()
	updated.emit(gradient, continuous_change)


class GradientCursor extends Control:
	
	signal double_clicked(gcursor)
	signal right_clicked(gcursor)
	signal pressed(gcursor)

	const WIDTH := 10
	
	var color: Color
	var is_sliding := false

	func _ready() -> void:
		position = Vector2(0, 15)
		size = Vector2(WIDTH, 15)

	func _draw() -> void:
		var polygon := PackedVector2Array(
			[
				Vector2(0, 5),
				Vector2(WIDTH / 2.0, 0),
				Vector2(WIDTH, 5),
				Vector2(WIDTH, 15),
				Vector2(0, 15),
				Vector2(0, 5)
			]
		)
		var c := color
		c.a = 1.0
		draw_colored_polygon(polygon, c)
		if color.v > 0.5:
			draw_polyline(polygon, Color(0.0, 0.0, 0.0))
		else:
			draw_polyline(polygon, Color(1.0, 1.0, 1.0))

	func _gui_input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton:
			if ev.button_index == MOUSE_BUTTON_LEFT:
				if ev.double_click:
					double_clicked.emit(self)
				elif ev.pressed:
					pressed.emit(self)
					is_sliding = true
				else:
					is_sliding = false
			elif ev.button_index == MOUSE_BUTTON_RIGHT:
				right_clicked.emit(self)

	func remove():
		queue_free()

	func _can_drop_data(_position, data) -> bool:
		return data is Color

	func _drop_data(_position, data):
		color = data
